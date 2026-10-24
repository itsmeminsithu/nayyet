# Holiday coverage

Checked: 2026-10-25. This is a curated selection, not a complete worldwide or Myanmar closure database.

- **2026 public holiday**: selected dates from Myanmar's Ministry of Foreign Affairs schedule, including New Year, Independence Day, Union Day, Peasants' Day, Armed Forces Day, Labour Day, Martyrs' Day, Christmas and the listed Thingyan, Waso, Thadingyut and Tazaungdaing closures.
- **Annual observance**: fixed-date Myanmar observances repeated from 2027 onward; not confirmed future closures.
- **Calculated calendar date**: Kason, Waso, Thadingyut and Tazaungmon full moons, National Day and Karen New Year, derived from the Myanmar calendar. These are not confirmations of additional days off.
- **International observance**: selected days such as New Year, Women's Day, World Water Day, World Environment Day, Peace Day, UN Day, Human Rights Day and Christmas. They are not public holidays in every country. In 2026, New Year and Christmas are labelled with their Myanmar public-holiday status.

Holiday entries cover 2026–2100. Dates before 2026 remain searchable and show lunar dates and daily quotes, but have no historical holiday dataset. No entry means no entry in this curated dataset, not proof of a working day. Eid, Deepavali, Chinese New Year, substitute holidays and later ad-hoc government closures are not yet included.

## Source reconciliation

MOFA's retrieved 2026 table lists Kason on May 30, while the eVisa search listing gives April 30; the calendar calculation also places Kason full moon on April 30. The conflicting Kason entry is deliberately labelled **calculated calendar date**, not a confirmed public holiday. National Day on December 4 agrees with the calendar and is included as a 2026 public holiday. Verify official notifications before using dates for work, banking or travel plans.

Sources:

- https://www.mofa.gov.mm/about-myanmar/public-holidays/
- https://evisa.moip.gov.mm/notice/public-holiday
- https://www.un.org/en/observances/list-days-weeks
- https://www.un.org/en/observances

Edit `tools/build_extras.py` to extend verified annual schedules or the selected observances, then run `python3 tools/build_calendar.py`. All three apps read the same generated data.
