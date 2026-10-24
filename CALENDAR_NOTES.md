# Calendar notes

NayYet supports Gregorian civil dates from 1900-01-01 through 2100-12-31 inclusive. Today is the calendar day in Myanmar Standard Time, UTC+06:30. UTC-based civil-day arithmetic avoids device daylight-saving transitions.

## Data generation

`tools/build_calendar.py` uses the published mean solar year (1577917828 / 4320000 days), mean lunar month (1577917828 / 53433336 days) and Myanmar epoch (Julian day 1954168.050623). It determines intercalary years, anchors the full moon of Second Waso, derives the beginning of Tagu, then enumerates lunar month lengths. A big intercalary year adds a day to Nayon. First Waso is inserted in intercalary years. Late Tagu and Late Kason retain distinct month identifiers.

The generator applies era-specific thresholds and published correction years within the supported range. It intentionally rejects older Myanmar eras. Extending the date range requires new era handling, reference verification and updating all platform bounds; changing only JSON metadata is insufficient.

The generated table has 2,681 intervals covering 73,414 dates. Each row contains:

`[unixDayStart, MyanmarYear, MyanmarMonth, lunarDayAtStart, yearType, lunarMonthLength]`

Month indices: 0 = First Waso, 1–12 = Tagu through Tabaung, 13 = Late Tagu, 14 = Late Kason. Month 4 is labelled Second Waso in intercalary years. Year types: 0 = common, 1 = little intercalary, 2 = big intercalary.

Each implementation finds the last interval starting on or before the requested date and adds the civil-day offset to its starting lunar day. Generated copies are committed so runtime apps require neither Python nor a remote service. Run the generator after changes and commit all copies together.

## Display rules

Full moon is lunar day 15; new moon is the last day of the lunar month. Sabbath days are 8, 15, 23 and the last day, with their preceding days marked as eves. Upcoming sabbaths include the selected day when applicable. Near the upper boundary, fewer than four future sabbaths may be available.

Moon symbols distinguish the four calendar phases. They are illustrative, not astronomical illumination estimates. Selected holiday entries are described in HOLIDAYS.md. This release does not supply event notifications, astrology or personal reminders. Calendar calculations do not establish future government holiday declarations.

## Technical references

- [Burmese calendar overview](https://en.wikipedia.org/wiki/Burmese_calendar)
- [Published Myanmar calendar calculation method](https://cool-emerald.blogspot.com/2013/06/algorithm-program-and-calculation-of.html)

Reference comparison details are recorded in TESTING.md.
