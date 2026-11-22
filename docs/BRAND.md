# Brand

**The Maker's Market**, in Arabic سوق الصنّاع. A shop for Egyptian handmade crafts that puts the maker first.

## Personality

Earthy, patterned and story-led. It is warm without being rustic-cute, and specific rather than generic: every piece has a workshop and a town.

## Colour

| Name | Hex | Use |
|---|---|---|
| Clay | `#B5532C` | Primary actions, prices, the logo arch |
| Indigo | `#2E3A59` | Feature bands, selected chips, avatars |
| Sand | `#F3EADB` | Page background |
| Paper | `#FFFBF5` | Cards and fields |
| Ink | `#2A211C` | Text |
| Olive | `#6B7A3A` | Secondary accents |
| Saffron | `#D9A441` | Eyebrows, ratings |

Dark mode swaps the backgrounds for warm browns (`#1C1714`, `#2A2420`) and lightens the clay to `#E08A62`.

## Type

- **Display:** Fraunces (Latin) with Amiri (Arabic) for titles, prices and section headings
- **Text:** Work Sans (Latin) with Readex Pro (Arabic)
- All four fonts are SIL Open Font License and bundled in `assets/fonts`.

## Shapes and motifs

- Small radii (6 px) on cards, fields and buttons, with thin sand-coloured borders instead of shadows
- The **arch**: a niche shape behind every product and in the logo
- The **zigzag**: a Nubian border used on feature bands
- Product art is flat cut paper: one base colour, one accent pattern band (waves, dots, zigzag, stripes or diamonds), a soft left highlight and a ground shadow

## Icons

Material Symbols, outlined, one style throughout.

## Things to avoid

Gradients, glassy cards, emoji in the interface, stock photography and generic e-commerce copy ("Find something you love").

## Font files

The bundled fonts are trimmed for the web, where Flutter downloads every font before the first frame: variable axes are pinned to the weights the app uses and each font keeps only the script it is used for (Latin or Arabic), with fontTools. Total: 1,381 KB to 505 KB.
