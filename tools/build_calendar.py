"""Build civil-day lookup intervals for 1900–2100. Min SiThu (itsmeminsithu), MIT.
Mathematical background and constants are documented in CALENDAR_NOTES.md.
"""
from datetime import date, timedelta
from functools import lru_cache
from math import floor
from pathlib import Path
import json

SOLAR = 1577917828 / 4320000
LUNAR = 1577917828 / 53433336
EPOCH = 1954168.050623
ROOT = Path(__file__).resolve().parents[1]

def leap_anchor(year):
    if year < 1217:
        raise ValueError('Builder supports the modern calendar eras only.')
    threshold_months = 8 if year >= 1312 else 4
    correction = -.5 if year >= 1312 else -1
    correction += {1234:1,1261:-1,1377:1}.get(year,0)
    remainder = (SOLAR*(year+3739)) % LUNAR
    annual_drift = SOLAR/12-LUNAR
    if remainder < annual_drift*(12-threshold_months): remainder += LUNAR
    intercalary = remainder >= LUNAR-annual_drift*threshold_months
    if year in (1263,1264,1344,1345): intercalary = not intercalary
    anchor = floor(SOLAR*year+EPOCH-remainder+4.5*LUNAR+correction+.5)
    return intercalary,anchor

@lru_cache(None)
def lunar_year(year):
    leap,anchor = leap_anchor(year)
    previous = year-1
    while not leap_anchor(previous)[0]: previous -= 1
    old_anchor = leap_anchor(previous)[1]
    year_type = 0
    if leap:
        extra = (anchor-old_anchor)%354
        if extra not in (30,31): raise ValueError(f'Invalid year structure: {year}')
        year_type = 1 if extra == 30 else 2
    start = old_anchor+354*(year-previous)-102
    return start,year_type

def convert(day):
    jdn = day.toordinal()+1721425
    year = floor((jdn-.5-EPOCH)/SOLAR)
    start,kind = lunar_year(year)
    offset = jdn-start
    sequence = [1,2,3]+([0] if kind else [])+list(range(4,13))+[13,14]
    for month in sequence:
        length = 30-month%2+(1 if month==3 and kind==2 else 0)
        if offset < length:
            assert offset >= 0
            return [year,month,offset+1,kind,length]
        offset -= length
    raise ValueError(f'Day not mapped: {day}')

def build():
    start,end = date(1900,1,1),date(2100,12,31)
    segments=[]
    current=start
    previous=None
    while current<=end:
        year,month,md,kind,length=convert(current)
        if previous is None or (year,month,kind)!=(previous[0],previous[1],previous[3]) or md!=previous[2]+1:
            segments.append([(current-date(1970,1,1)).days,year,month,md,kind,length])
        previous=[year,month,md,kind,length]
        current+=timedelta(days=1)
    data={'version':1,'from':start.isoformat(),'to':end.isoformat(),'epoch':'1970-01-01','segments':segments}
    from build_extras import enrich
    data=enrich(data)
    raw=json.dumps(data,separators=(',',':'),ensure_ascii=False)+'\n'
    for target in ['shared/calendar.json','web/assets/calendar.json','android_flutter/assets/calendar.json','ios_swift/NayYet/Resources/calendar.json','ios_swift/NayYetTests/Fixtures/calendar.json']:
        (ROOT/target).write_text(raw,encoding='utf-8')
    samples=['1900-01-01','1902-06-01','1950-04-17','1982-08-01','1983-08-01','2000-01-01','2015-08-01','2023-08-01','2024-04-17','2026-10-25','2026-10-26','2027-04-17','2100-12-31']
    vectors=[{'date':s,'expected':convert(date.fromisoformat(s))} for s in samples]
    (ROOT/'shared/test-vectors.json').write_text(json.dumps(vectors,indent=2)+'\n',encoding='utf-8')
    (ROOT/'ios_swift/NayYetTests/Fixtures/test-vectors.json').write_text(json.dumps(vectors,indent=2)+'\n',encoding='utf-8')
    print(f'{len(segments)} intervals cover {(end-start).days+1} dates.')
if __name__=='__main__':build()
