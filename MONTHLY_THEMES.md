# Monthly themes

Twelve bundled scenes change with the Gregorian month being viewed. Date search updates the month and scene. Quote export uses the selected date’s month; browsing another month does not change the selected date.

| Month | Scene |
| --- | --- |
| January | Starlit beginnings |
| February | Bagan at dawn |
| March | A Myanmar village |
| April | Ngapali coast |
| May | Taunggyi mountain morning |
| June | Monsoon valley |
| July | Inle Lake reflections |
| August | Cosmic drift |
| September | City after sunset |
| October | Pagodas in lantern light |
| November | A sky of stars |
| December | Winter universe |

Web and iOS also change page colors. Android changes its header artwork and quote accent. The calendar controls stay in consistent positions. All scenes work offline.

Edit `shared/themes.json` and `tools/build_themes.py` to customize artwork. Editable SVGs and 1600 × 900 PNGs are in `shared/themes/`. Artwork is covered by the project MIT license. These are stylized illustrations, not photographs of specific monuments.

To rebuild artwork (optional; PNGs are already included):
```sh
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install cairosvg
python3 tools/build_themes.py
python3 tools/build_calendar.py
```
CairoSVG may require the Cairo system library. It is only a development dependency, not an app dependency.

Version 1.3.0 adds stylized Myanmar destination scenery: Bagan in February, a village in March, Ngapali coast in April, Taunggyi in May, and Inle Lake in July. These are illustrations evoking each setting, not geographical reproductions or photographs. Centered landmarks remain visible in portrait quote exports.
