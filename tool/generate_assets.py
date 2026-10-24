from PIL import Image, ImageDraw, ImageFilter, ImageFont

S = 2
W, H = 800 * S, 700 * S
img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
d = ImageDraw.Draw(img)


def hexc(h, a=255):
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), a)


INK = hexc("0B1020")
DARK = hexc("151C31")
BORDER = hexc("2B3554")
VIOLET = hexc("6D4DF6")
MINT = hexc("2DD4BF")
MINT2 = hexc("5EEAD4")
AMBER = hexc("FFB547")
AMBER2 = hexc("FFD08A")
WHITE = hexc("FFFFFF")


def sc(v):
    return int(v * S)


def shadow(box, blur=28, alpha=120, offset=(0, 18)):
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ld = ImageDraw.Draw(layer)
    x0, y0, x1, y1 = box
    ld.rounded_rectangle(
        [
            sc(x0) + offset[0] * S,
            sc(y0) + offset[1] * S,
            sc(x1) + offset[0] * S,
            sc(y1) + offset[1] * S,
        ],
        radius=sc(30),
        fill=(0, 0, 0, alpha),
    )
    return layer.filter(ImageFilter.GaussianBlur(blur * S / 2))


def grad_round(box, radius, top, bottom, outline=None, width=2):
    x0, y0, x1, y1 = [sc(v) for v in box]
    w, h = x1 - x0, y1 - y0
    base = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    bd = ImageDraw.Draw(base)
    for i in range(h):
        t = i / (h - 1)
        c = tuple(int(top[j] + (bottom[j] - top[j]) * t) for j in range(4))
        bd.line([(0, i), (w, i)], fill=c)
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, w - 1, h - 1], radius=sc(radius), fill=255)
    base.putalpha(mask)
    img.alpha_composite(base, (x0, y0))
    if outline:
        d.rounded_rectangle([x0, y0, x1, y1], radius=sc(radius), outline=outline, width=width * S)


# Ground shadow
ground = Image.new("RGBA", (W, H), (0, 0, 0, 0))
ImageDraw.Draw(ground).ellipse([sc(150), sc(600), sc(690), sc(665)], fill=(5, 8, 20, 130))
img.alpha_composite(ground.filter(ImageFilter.GaussianBlur(30 * S)))

# POS tablet
img.alpha_composite(shadow((230, 90, 620, 590), blur=34, alpha=110, offset=(0, 24)))
grad_round((230, 90, 620, 590), 40, DARK, hexc("0E1425"), outline=BORDER, width=2)
d.rounded_rectangle([sc(240), sc(100), sc(610), sc(120)], radius=sc(20), fill=(255, 255, 255, 18))
img.alpha_composite(shadow((252, 118, 598, 552), blur=10, alpha=60, offset=(0, 4)))
grad_round((252, 118, 598, 552), 28, hexc("6C4DF6"), hexc("3A2AC0"))

gl = Image.new("RGBA", (W, H), (0, 0, 0, 0))
ImageDraw.Draw(gl).ellipse([sc(300), sc(130), sc(620), sc(430)], fill=(255, 255, 255, 18))
img.alpha_composite(gl.filter(ImageFilter.GaussianBlur(50 * S)))

d.rounded_rectangle([sc(276), sc(146), sc(392), sc(178)], radius=sc(16), fill=(255, 255, 255, 36))
d.ellipse([sc(288), sc(155), sc(300), sc(167)], fill=MINT)
d.rounded_rectangle([sc(308), sc(157), sc(376), sc(166)], radius=sc(4), fill=(255, 255, 255, 210))

d.rounded_rectangle(
    [sc(276), sc(200), sc(574), sc(390)],
    radius=sc(22),
    fill=(10, 14, 32, 88),
    outline=(255, 255, 255, 52),
    width=S,
)
for i, (bh, c) in enumerate(zip([78, 118, 150, 178], [(255, 255, 255, 235), MINT, AMBER, (255, 255, 255, 200)])):
    x = sc(310 + i * 60)
    d.rounded_rectangle([x, sc(360 - bh * 0.55), x + sc(30), sc(360)], radius=sc(10), fill=c)

pts = [
    (sc(300), sc(320)),
    (sc(350), sc(292)),
    (sc(400), sc(304)),
    (sc(452), sc(250)),
    (sc(510), sc(262)),
    (sc(560), sc(216)),
]
d.line(pts, fill=(255, 255, 255, 240), width=sc(4), joint="curve")
for p in pts:
    d.ellipse([p[0] - sc(4), p[1] - sc(4), p[0] + sc(4), p[1] + sc(4)], fill=WHITE)

for i in range(2):
    y = 412 + i * 60
    d.rounded_rectangle([sc(276), sc(y), sc(574), sc(y + 48)], radius=sc(14), fill=(255, 255, 255, 30))
    d.rounded_rectangle([sc(290), sc(y + 13), sc(312), sc(y + 35)], radius=sc(7), fill=MINT if i == 0 else AMBER)
    d.rounded_rectangle([sc(326), sc(y + 15), sc(430), sc(y + 24)], radius=sc(4), fill=(255, 255, 255, 220))
    d.rounded_rectangle([sc(326), sc(y + 29), sc(392), sc(y + 35)], radius=sc(3), fill=(255, 255, 255, 120))
    d.rounded_rectangle([sc(500), sc(y + 16), sc(560), sc(y + 32)], radius=sc(8), fill=(255, 255, 255, 210))

d.rounded_rectangle([sc(396), sc(566), sc(454), sc(574)], radius=sc(4), fill=(255, 255, 255, 70))

# Receipt
receipt = Image.new("RGBA", (sc(220), sc(320)), (0, 0, 0, 0))
rd = ImageDraw.Draw(receipt)
rd.rounded_rectangle([0, 0, sc(220) - 1, sc(260)], radius=sc(14), fill=(255, 255, 255, 247))
for i in range(9):
    x = sc(6 + i * 24)
    rd.polygon([(x, sc(258)), (x + sc(12), sc(258)), (x + sc(6), sc(278))], fill=(255, 255, 255, 247))
rd.rounded_rectangle([sc(24), sc(28), sc(120), sc(40)], radius=sc(5), fill=(30, 36, 58, 200))
rd.rounded_rectangle([sc(24), sc(56), sc(196), sc(64)], radius=sc(4), fill=(160, 168, 190, 180))
rd.rounded_rectangle([sc(24), sc(74), sc(150), sc(82)], radius=sc(4), fill=(190, 196, 214, 160))
for i in range(4):
    y = 112 + i * 26
    rd.rounded_rectangle([sc(24), sc(y), sc(120), sc(y + 8)], radius=sc(4), fill=(180, 188, 208, 180))
    rd.rounded_rectangle([sc(160), sc(y), sc(198), sc(y + 8)], radius=sc(4), fill=(120, 130, 155, 200))
rd.line([sc(24), sc(212), sc(198), sc(212)], fill=(220, 224, 235, 255), width=sc(2))
rd.rounded_rectangle([sc(24), sc(226), sc(100), sc(238)], radius=sc(5), fill=(40, 46, 70, 220))
rd.rounded_rectangle([sc(144), sc(226), sc(198), sc(240)], radius=sc(6), fill=VIOLET)
receipt = receipt.rotate(-7, expand=True, resample=Image.BICUBIC)
img.alpha_composite(receipt, (sc(500), sc(480)))

# Shopping bag
img.alpha_composite(shadow((34, 300, 214, 540), blur=26, alpha=90, offset=(0, 18)))
ImageDraw.Draw(img).arc(
    [sc(72), sc(240), sc(176), sc(360)], start=180, end=360, fill=(255, 255, 255, 225), width=sc(12)
)
grad_round((34, 320, 214, 548), 34, MINT2, hexc("0FA98F"), outline=(255, 255, 255, 80), width=2)
d.rounded_rectangle([sc(48), sc(336), sc(200), sc(350)], radius=sc(8), fill=(255, 255, 255, 40))


def bolt(cx, cy, s, color):
    pts = [
        (cx, cy - s),
        (cx - s * 0.55, cy + s * 0.12),
        (cx - s * 0.08, cy + s * 0.12),
        (cx - s * 0.35, cy + s),
        (cx + s * 0.6, cy - s * 0.18),
        (cx + s * 0.1, cy - s * 0.18),
    ]
    d.polygon([(sc(x), sc(y)) for x, y in pts], fill=color)


bolt(124, 438, 58, (255, 255, 255, 235))

# Card reader
img.alpha_composite(shadow((608, 330, 760, 570), blur=24, alpha=95, offset=(0, 18)))
grad_round((610, 334, 754, 566), 28, DARK, hexc("0C1222"), outline=BORDER, width=2)
grad_round((630, 362, 734, 468), 16, MINT, hexc("0E9F8C"))
for r in (12, 24, 36):
    d.arc([sc(682 - r), sc(400 - r), sc(682 + r), sc(400 + r)], start=200, end=340, fill=(255, 255, 255, 220), width=sc(3))
for r in range(3):
    for c in range(3):
        x, y = 642 + c * 34, 492 + r * 22
        d.rounded_rectangle([sc(x), sc(y), sc(x + 22), sc(y + 12)], radius=sc(5), fill=(255, 255, 255, 38))

# Payment card
card = Image.new("RGBA", (sc(230), sc(146)), (0, 0, 0, 0))
cd = ImageDraw.Draw(card)
for y in range(sc(146)):
    t = y / (sc(146) - 1)
    cd.line([(0, y), (sc(230), y)], fill=tuple(int(AMBER[j] + (AMBER2[j] - AMBER[j]) * t) for j in range(4)))
mask = Image.new("L", card.size, 0)
ImageDraw.Draw(mask).rounded_rectangle([0, 0, sc(230) - 1, sc(146) - 1], radius=sc(22), fill=255)
card.putalpha(mask)
cd.rounded_rectangle([sc(24), sc(36), sc(60), sc(62)], radius=sc(6), fill=(255, 255, 255, 190))
cd.rounded_rectangle([sc(24), sc(98), sc(128), sc(108)], radius=sc(4), fill=(30, 36, 58, 150))
cd.rounded_rectangle([sc(24), sc(114), sc(86), sc(122)], radius=sc(4), fill=(30, 36, 58, 90))
cd.ellipse([sc(166), sc(92), sc(208), sc(134)], fill=(255, 255, 255, 70))
cd.ellipse([sc(186), sc(92), sc(228), sc(134)], fill=(255, 255, 255, 45))
card = card.rotate(9, expand=True, resample=Image.BICUBIC)
img.alpha_composite(card, (sc(586), sc(176)))

# Coins
try:
    coin_font = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", sc(24))
    coin_font_small = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", sc(15))
    has_font = True
except Exception:
    has_font = False

for cx, cy, r in [(92, 236, 28), (52, 192, 17), (742, 596, 24), (696, 626, 15)]:
    d.ellipse([sc(cx - r), sc(cy - r), sc(cx + r), sc(cy + r)], fill=AMBER, outline=(255, 255, 255, 150), width=S)
    d.ellipse(
        [sc(cx - r + 5), sc(cy - r + 5), sc(cx + r - 5), sc(cy + r - 5)],
        outline=(255, 255, 255, 90),
        width=S,
    )
    if has_font:
        f = coin_font if r > 20 else coin_font_small
        d.text((sc(cx), sc(cy + 1)), "$", font=f, fill=(120, 74, 10, 220), anchor="mm")
    else:
        d.rounded_rectangle([sc(cx - 2), sc(cy - r + 8), sc(cx + 2), sc(cy + r - 8)], radius=sc(2), fill=(255, 255, 255, 190))
        d.rounded_rectangle([sc(cx - 8), sc(cy - 2), sc(cx + 8), sc(cy + 2)], radius=sc(2), fill=(255, 255, 255, 190))


def sparkle(cx, cy, s, c):
    d.polygon(
        [
            (sc(cx), sc(cy - s)),
            (sc(cx + s * 0.25), sc(cy - s * 0.25)),
            (sc(cx + s), sc(cy)),
            (sc(cx + s * 0.25), sc(cy + s * 0.25)),
            (sc(cx), sc(cy + s)),
            (sc(cx - s * 0.25), sc(cy + s * 0.25)),
            (sc(cx - s), sc(cy)),
            (sc(cx - s * 0.25), sc(cy - s * 0.25)),
        ],
        fill=c,
    )


sparkle(300, 150, 12, (255, 255, 255, 200))
sparkle(690, 120, 9, (255, 255, 255, 170))
sparkle(70, 470, 8, (255, 255, 255, 150))
sparkle(760, 300, 7, (255, 255, 255, 140))

img = img.resize((800, 700), Image.LANCZOS)
img.save("assets/images/pos_illustration.png")
print("saved")
