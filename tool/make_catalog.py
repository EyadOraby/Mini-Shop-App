"""Builds the Maker's Market catalogue (assets/products.json and site/api/products.json).

Makers are fictional demo workshops; crafts and regions are real Egyptian traditions.
Each product's `image` is an art spec drawn in code: art:<kind>:<base>:<accent>:<pattern>.
"""
import json
import os

CLAY, INDIGO, SAND, OLIVE, INK, SAFFRON, ROSE, TEAL = 'B5532C', '2E3A59', 'E9D8BE', '6B7A3A', '2A211C', 'D9A441', 'C9786A', '2F6F6A'

P = [
    # pottery
    ('Tunis Village glazed vase', 'pottery', 1450, 4.9, 86, 'Rawya\'s studio', 'Tunis Village, Fayoum',
     'Wheel-thrown and glazed by hand in the potters\' village on Lake Qarun, with the birds and palms the village is known for.', 'vase', CLAY, SAND, 'waves'),
    ('Garagos serving bowl', 'pottery', 780, 4.8, 54, 'Garagos Pottery Guild', 'Garagos, Qena',
     'A deep bowl in the earthy glazes Garagos has fired since the 1950s. Food safe and made for everyday use.', 'bowl', OLIVE, SAND, 'dots'),
    ('Fayoum breakfast plates, set of 4', 'pottery', 1200, 4.7, 39, 'Rawya\'s studio', 'Tunis Village, Fayoum',
     'Four plates, each painted by hand, so no two are quite the same.', 'plate', TEAL, SAND, 'zigzag'),
    # textiles
    ('Akhmim hand-woven cotton throw', 'textiles', 1950, 4.9, 61, 'Akhmim Weavers', 'Akhmim, Sohag',
     'Woven on a wooden loom from Egyptian cotton in a town that has woven cloth since pharaonic times.', 'rug', INDIGO, SAND, 'stripes'),
    ('Siwa embroidered cushion cover', 'textiles', 650, 4.8, 72, 'Siwa Stitch', 'Siwa Oasis',
     'Black cotton with the oasis\'s red, orange and green embroidery and mother-of-pearl buttons.', 'cushion', INK, CLAY, 'diamond'),
    ('Fowa kilim rug, 120 × 180 cm', 'textiles', 4800, 4.9, 28, 'Fowa Loom House', 'Fowa, Kafr El Sheikh',
     'A flat-woven wool kilim in natural dyes, made on the floor looms Fowa is famous for.', 'rug', CLAY, SAFFRON, 'diamond'),
    ('Akhmim linen scarf', 'textiles', 520, 4.6, 44, 'Akhmim Weavers', 'Akhmim, Sohag',
     'Light, loose-woven linen with a hand-knotted fringe.', 'scarf', SAFFRON, INDIGO, 'stripes'),
    # baskets
    ('Nubian palm-frond basket', 'baskets', 690, 4.8, 93, 'Gharb Soheil Makers', 'Gharb Soheil, Aswan',
     'Coiled from dyed palm fronds in the bright colours of the Nubian villages on the west bank of the Nile.', 'basket', SAFFRON, ROSE, 'zigzag'),
    ('Fayoum market basket', 'baskets', 420, 4.7, 58, 'Fayoum Palm Craft', 'Fayoum',
     'A sturdy everyday basket with leather handles, woven from date-palm leaves.', 'basket', OLIVE, CLAY, 'stripes'),
    ('Nubian lidded bread basket', 'baskets', 850, 4.9, 31, 'Gharb Soheil Makers', 'Gharb Soheil, Aswan',
     'A tall coiled basket with a conical lid, made to keep bread fresh.', 'basket', ROSE, INDIGO, 'dots'),
    # lighting
    ('Khan el-Khalili brass lantern', 'lighting', 2300, 4.8, 66, 'El Moez Metalworks', 'Al-Muizz Street, Cairo',
     'Hand-pierced brass that throws a starry pattern on the walls when lit.', 'lantern', SAFFRON, INK, 'dots'),
    ('Copper pendant lamp', 'lighting', 3100, 4.7, 22, 'El Moez Metalworks', 'Al-Muizz Street, Cairo',
     'Hammered and engraved copper, wired and ready to hang.', 'lamp', CLAY, SAFFRON, 'diamond'),
    ('Fanoos table lamp', 'lighting', 1650, 4.6, 48, 'Bab Zuweila Lights', 'Bab Zuweila, Cairo',
     'A small tin-and-glass fanoos in the shape of the classic Ramadan lantern.', 'lantern', TEAL, SAFFRON, 'waves'),
    # glass
    ('Hand-blown glass tumblers, set of 6', 'glass', 900, 4.8, 75, 'Bab El Shaariya Glass', 'Bab El Shaariya, Cairo',
     'Recycled glass blown by hand, with the small bubbles that give it its character.', 'glass', TEAL, SAND, 'none'),
    ('Hand-blown glass carafe', 'glass', 750, 4.7, 37, 'Bab El Shaariya Glass', 'Bab El Shaariya, Cairo',
     'A one-litre carafe in sea-green recycled glass.', 'glass', OLIVE, SAND, 'none'),
    # jewellery
    ('Siwa silver necklace', 'jewellery', 2600, 4.9, 34, 'Siwa Silver', 'Siwa Oasis',
     'Sterling silver in the traditional Siwan disc design, made by hand.', 'necklace', 'A7A9AC', INDIGO, 'dots'),
    ('Nubian beaded bracelet', 'jewellery', 380, 4.7, 88, 'Gharb Soheil Makers', 'Gharb Soheil, Aswan',
     'Glass beads strung in the zigzag pattern painted on Nubian houses.', 'bracelet', ROSE, SAFFRON, 'zigzag'),
    ('Khan el-Khalili silver cuff', 'jewellery', 1900, 4.8, 26, 'El Moez Metalworks', 'Al-Muizz Street, Cairo',
     'An engraved sterling silver cuff with an arabesque border.', 'bracelet', 'A7A9AC', CLAY, 'waves'),
]

out = []
for i, (title, cat, price, rate, count, maker, region, desc, kind, base, accent, pattern) in enumerate(P, 1):
    out.append({
        'id': i, 'title': title, 'price': price, 'description': desc, 'category': cat,
        'image': f'art:{kind}:{base}:{accent}:{pattern}', 'rating': {'rate': rate, 'count': count},
        'maker': maker, 'region': region,
    })

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
for path in ['assets/products.json', 'site/api/products.json']:
    full = os.path.join(root, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, 'w', encoding='utf8') as f:
        json.dump(out, f, ensure_ascii=False, indent=1)
print(len(out), 'products')
