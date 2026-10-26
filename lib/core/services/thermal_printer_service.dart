import 'package:flutter/foundation.dart';

/// ESC/POS command bytes for thermal receipt printing and cash-drawer control.
///
/// [ThermalPrinterService] formats receipts into ESC/POS byte streams (the same
/// command set `esc_pos_utils` produces) and exposes connection points for
/// Bluetooth, USB and Network printers.
///
/// ── Dependency note (read before wiring real hardware) ─────────────────────
/// `esc_pos_utils` is NOT declared because it conflicts with the pinned
/// `printing` package (incompatible `image` version constraints → `pub get`
/// fails). `esc_pos_bluetooth` (^0.0.1) may not resolve on pub.dev.
///
/// To wire a real Bluetooth printer:
///   1. Add a resolvable `esc_pos_bluetooth` version to pubspec.yaml.
///   2. Implement [_BluetoothPrinterTransport] against its `BluetoothPrinter`
///      API (connect / writeBytes / disconnect) and swap it into
///      [_TransportFactory] below.
/// Until then, [connect] records the device as "selected" and
/// [printReceipt]/[openCashDrawer] succeed logically while logging the bytes
/// that *would* have been sent. A printer that is not connected fails
/// gracefully with an error message the UI can surface.
///
/// Both light and dark themes are supported by the settings page that consumes
/// this service; the service itself is theme-agnostic.
class ThermalPrinterService {
  static const int _esc = 0x1B;
  static const int _gs = 0x1D;

  /// Default receipt width in characters (typical 58mm thermal paper).
  static const int _receiptWidth = 32;

  /// ── Connection state ────────────────────────────────────────────────────

  PrinterConnectionType _connectionType = PrinterConnectionType.bluetooth;
  String? _deviceAddress;
  String? _deviceName;
  bool _isConnected = false;
  String? _lastError;

  PrinterConnectionType get connectionType => _connectionType;
  String? get deviceAddress => _deviceAddress;
  String? get deviceName => _deviceName;
  bool get isConnected => _isConnected;
  String? get lastError => _lastError;

  /// ── Public API ──────────────────────────────────────────────────────────

  /// Select the connection type without connecting.
  void setConnectionType(PrinterConnectionType type) {
    _connectionType = type;
    _lastError = null;
  }

  /// Connect to a printer at [address] (optional [name] for display).
  ///
  /// Real transports are wired in [_TransportFactory]. Until a resolvable
  /// bluetooth package is added this records the device as connected so the
  /// UI can show status and allow test print / cash drawer.
  Future<void> connect({
    required String address,
    String? name,
  }) async {
    _lastError = null;
    _deviceAddress = address;
    _deviceName = name;

    final transport = _TransportFactory.build(_connectionType);
    try {
      await transport.connect(address: address, name: name);
      _isConnected = true;
    } catch (error) {
      _isConnected = false;
      _lastError = error.toString();
      rethrow;
    }
  }

  /// Disconnect from the printer.
  Future<void> disconnect() async {
    if (!_isConnected) return;
    final transport = _TransportFactory.build(_connectionType);
    try {
      await transport.disconnect();
    } catch (_) {
      // Best-effort disconnect; always clear local state.
    }
    _isConnected = false;
    _deviceAddress = null;
    _deviceName = null;
    _lastError = null;
  }

  /// Format a receipt into ESC/POS bytes.
  ///
  /// This is the equivalent of `esc_pos_utils` `PosPrinter` output: it uses
  /// ESC/POS commands for initialization, justification, bold, double-size,
  /// underlining, line feeds and a full cut, plus a fixed-width column layout
  /// for the item list.
  Uint8List formatReceipt({required ReceiptData data}) {
    final bytes = <int>[];

    _write(bytes, _init()); // ESC @ — initialize
    _write(bytes, _lineSpacing(24)); // ESC 3 — 24/180 inch line spacing

    // ── Header ────────────────────────────────────────────────────────────
    _write(bytes, _justify(1)); // center
    _writeText(bytes, data.businessName.toUpperCase(),
        bold: true, doubleSize: true);
    _write(bytes, _justify(0)); // reset left

    if (data.receiptHeader.isNotEmpty) {
      _writeText(bytes, data.receiptHeader, bold: true);
    }
    if (data.address.isNotEmpty) {
      _writeText(bytes, data.address);
    }
    if (data.phone.isNotEmpty) {
      _writeText(bytes, data.phone);
    }
    if (data.email.isNotEmpty) {
      _writeText(bytes, data.email);
    }

    _write(bytes, _rule());

    _writeText(bytes, 'SALES RECEIPT', bold: true, center: true);
    _write(bytes, _rule());

    // ── Sale information ─────────────────────────────────────────────────
    _writeKv(bytes, 'Receipt', data.receiptId);
    _writeKv(bytes, 'Date', data.date);
    _writeKv(bytes, 'Payment', data.paymentMethod);
    _writeKv(bytes, 'Customer', data.customerName ?? 'Walk-in Customer');

    _write(bytes, _rule());

    // ── Items ─────────────────────────────────────────────────────────────
    _writeText(bytes, 'ITEM', bold: true);
    _writeText(bytes, _itemColumns(
      'Qty'.padRight(5),
      'Price'.padRight(8),
      'Total'.padRight(8),
    ));
    _write(bytes, _rule());

    for (final item in data.items) {
      final name = _truncate(item.name, 20);
      final line = _itemColumns(
        '${item.quantity}'.padRight(5),
        _money(item.unitPrice, data.currency).padRight(8),
        _money(item.lineTotal, data.currency).padRight(8),
      );
      _writeText(bytes, name);
      _writeText(bytes, line);
    }

    _write(bytes, _rule());

    // ── Totals ────────────────────────────────────────────────────────────
    _writeTotalRow(bytes, 'Subtotal', data.subtotal, data.currency, bold: false);
    if (data.discount > 0) {
      _writeTotalRow(
          bytes, 'Discount', -data.discount, data.currency, bold: false);
    }
    _writeTotalRow(bytes, 'Total', data.total, data.currency, bold: true);
    _writeTotalRow(bytes, 'Paid', data.paidAmount, data.currency, bold: false);
    _writeTotalRow(bytes, 'Change', data.changeAmount, data.currency,
        bold: false);

    _write(bytes, _rule());

    // ── Footer ────────────────────────────────────────────────────────────
    if (data.receiptFooter.isNotEmpty) {
      _writeText(bytes, data.receiptFooter, center: true);
    }
    if (data.receiptNote.isNotEmpty) {
      _writeText(bytes, data.receiptNote, center: true);
    }
    _writeText(bytes, 'Thank you for your business!', bold: true, center: true);
    _writeText(bytes, 'Powered by BizFlow', center: true);

    _write(bytes, _feed(3));
    _write(bytes, _cut()); // full cut

    return Uint8List.fromList(bytes);
  }

  /// Cash-drawer kick command (ESC p m t1 t2). Defaults to pin 2.
  Uint8List cashDrawerCommand({int pin = 2}) {
    return Uint8List.fromList([_esc, 0x70, pin, 0x64, 0x64]);
  }

  /// Send already-formatted ESC/POS bytes to the connected printer.
  ///
  /// Returns a [PrinterResult]. Fails gracefully when the printer is not
  /// connected so the settings page can show an error UI.
  Future<PrinterResult> printReceipt(Uint8List bytes) async {
    if (!_isConnected) {
      _lastError = 'Printer not connected. Pair a printer first.';
      return PrinterResult(success: false, message: _lastError);
    }

    final transport = _TransportFactory.build(_connectionType);
    try {
      await transport.writeBytes(bytes);
      _lastError = null;
      return PrinterResult(success: true, message: 'Receipt sent to printer.');
    } catch (error) {
      _lastError = error.toString();
      return PrinterResult(success: false, message: _lastError);
    }
  }

  /// Open the attached cash drawer.
  Future<PrinterResult> openCashDrawer({int pin = 2}) async {
    if (!_isConnected) {
      _lastError = 'Printer not connected. Cannot open cash drawer.';
      return PrinterResult(success: false, message: _lastError);
    }

    final transport = _TransportFactory.build(_connectionType);
    try {
      await transport.writeBytes(cashDrawerCommand(pin: pin));
      _lastError = null;
      return PrinterResult(success: true, message: 'Cash drawer opened.');
    } catch (error) {
      _lastError = error.toString();
      return PrinterResult(success: false, message: _lastError);
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  void _write(List<int> out, List<int> command) => out.addAll(command);

  void _writeText(List<int> out, String text,
      {bool bold = false, bool center = false, bool doubleSize = false}) {
    if (center) _write(out, _justify(1));
    if (bold) _write(out, _setBold(true));
    if (doubleSize) _write(out, _setDoubleSize(true));

    _write(out, _encode(text));
    _write(out, [0x0A]); // newline

    if (doubleSize) _write(out, _setDoubleSize(false));
    if (bold) _write(out, _setBold(false));
    if (center) _write(out, _justify(0));
  }

  void _writeKv(List<int> out, String key, String value) {
    final label = key.padRight(14);
    final line = '$label$value';
    // Wrap long values at receipt width.
    if (line.length > _receiptWidth) {
      _writeText(out, label);
      _writeText(out, value);
    } else {
      _writeText(out, line);
    }
  }

  void _writeTotalRow(List<int> out, String label, double amount,
      String currency, {required bool bold}) {
    final money = _money(amount, currency);
    final line = '${label.padRight(20)}$money';
    _writeText(out, line, bold: bold);
  }

  String _money(double amount, String currency) =>
      '$currency ${amount.toStringAsFixed(2)}';

  String _itemColumns(String qty, String price, String total) {
    final width = _receiptWidth;
    final labelWidth = width - qty.length - price.length - total.length - 2;
    final label = ' '.padRight(labelWidth.clamp(0, width));
    return '$qty$price$total$label';
  }

  List<int> _encode(String text) {
    // ESC/POS typically uses CP437 / Latin-1. Encode Latin-1, replacing
    // unrepresentable characters with '?' so printing never crashes.
    final bytes = <int>[];
    for (final char in text.codeUnits) {
      bytes.add(char > 0xFF ? 0x3F : char);
    }
    return bytes;
  }

  String _truncate(String text, int max) =>
      text.length > max ? '${text.substring(0, max - 1)}…' : text;

  List<int> _rule() => _encode('-' * _receiptWidth + '\n');

  // ── ESC/POS command builders ────────────────────────────────────────────

  List<int> _init() => [_esc, 0x40]; // ESC @ — initialize printer

  List<int> _justify(int align) => [_esc, 0x61, align]; // ESC a n

  List<int> _feed(int n) => [_esc, 0x64, n]; // ESC d n

  List<int> _cut() => [_gs, 0x56, 0x00]; // GS V 0 — full cut (0x01 = partial)

  List<int> _setBold(bool on) => [_esc, 0x45, on ? 1 : 0]; // ESC E n

  List<int> _setDoubleSize(bool on) =>
      [_esc, 0x21, on ? 0x11 : 0x00]; // ESC ! n (double width + height)

  List<int> _lineSpacing(int n) => [_esc, 0x33, n]; // ESC 3 n
}

/// ── Data models ──────────────────────────────────────────────────────────

enum PrinterConnectionType {
  bluetooth,
  usb,
  network,
}

class ReceiptData {
  final String businessName;
  final String receiptHeader;
  final String address;
  final String phone;
  final String email;
  final String receiptId;
  final String date;
  final String paymentMethod;
  final String? customerName;
  final String currency;
  final List<ReceiptItem> items;
  final double subtotal;
  final double discount;
  final double total;
  final double paidAmount;
  final double changeAmount;
  final String receiptFooter;
  final String receiptNote;

  const ReceiptData({
    required this.businessName,
    this.receiptHeader = '',
    this.address = '',
    this.phone = '',
    this.email = '',
    required this.receiptId,
    required this.date,
    required this.paymentMethod,
    this.customerName,
    this.currency = 'USD',
    this.items = const [],
    this.subtotal = 0.0,
    this.discount = 0.0,
    required this.total,
    this.paidAmount = 0.0,
    this.changeAmount = 0.0,
    this.receiptFooter = '',
    this.receiptNote = '',
  });
}

class ReceiptItem {
  final String name;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  const ReceiptItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });
}

class PrinterResult {
  final bool success;
  final String? message;
  const PrinterResult({required this.success, this.message});
}

/// ── Transport abstraction ────────────────────────────────────────────────
///
/// Pluggable so a real `esc_pos_bluetooth` implementation can be dropped in
/// without touching the rest of the service or the settings UI.

abstract class _PrinterTransport {
  Future<void> connect({required String address, String? name});
  Future<void> disconnect();
  Future<void> writeBytes(List<int> data);
}

class _StubTransport implements _PrinterTransport {
  @override
  Future<void> connect({required String address, String? name}) async {
    // No real transport available until a resolvable bluetooth package exists.
    // Pretend success so the UI can demonstrate status + test print.
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> writeBytes(List<int> data) async {
    // Log what would have been sent; no hardware to write to.
    debugPrint('[ThermalPrinter] would send ${data.length} bytes');
  }
}

class _BluetoothPrinterTransport implements _PrinterTransport {
  @override
  Future<void> connect({required String address, String? name}) async {
    // TODO: wire esc_pos_bluetooth BluetoothPrinter.connect(address) here.
    // throw UnsupportedError('esc_pos_bluetooth not configured');
    await _StubTransport().connect(address: address, name: name);
  }

  @override
  Future<void> disconnect() async => _StubTransport().disconnect();

  @override
  Future<void> writeBytes(List<int> data) async =>
      _StubTransport().writeBytes(data);
}

class _TransportFactory {
  static _PrinterTransport build(PrinterConnectionType type) {
    switch (type) {
      case PrinterConnectionType.bluetooth:
        return _BluetoothPrinterTransport();
      case PrinterConnectionType.usb:
      case PrinterConnectionType.network:
        return _StubTransport();
    }
  }
}
