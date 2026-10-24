import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {Calendar, dayNumber, isoFromDay, myanmarToday, digits} from '../calendar.js';
const read = path => JSON.parse(readFileSync(new URL(path, import.meta.url)));
const data = read('../assets/calendar.json');
const calendar = new Calendar(data);

test('historical corrections, leap years and boundary fixtures', () => {
  for (const {date, expected} of read('../../shared/test-vectors.json')) {
    const d = calendar.get(date);
    assert.deepEqual([d.year, d.month, d.md, d.type, d.length], expected, date);
  }
});
test('every supported date has a valid lunar day and phase', () => {
  let count = 0;
  for (let n = calendar.from; n <= calendar.to; n++) {
    const d = calendar.get(isoFromDay(n));
    assert.ok(d.md >= 1 && d.md <= d.length);
    assert.ok(d.length === 29 || d.length === 30);
    assert.ok(d.month >= 0 && d.month <= 14);
    assert.equal(d.phase === 1, d.md === 15);
    assert.equal(d.phase === 3, d.md === d.length);
    count++;
  }
  assert.equal(count, 73414);
});
test('invalid and unsupported civil dates fail', () => {
  for (const date of ['2026-02-29','2024-02-30','2026-13-01','2026-1-01','abc']) assert.throws(() => dayNumber(date));
  for (const date of ['1899-12-31','2101-01-01']) assert.throws(() => calendar.get(date), RangeError);
});
test('Myanmar day changes at 17:30 UTC independently of host timezone', () => {
  assert.equal(myanmarToday(Date.parse('2026-10-24T17:29:59Z')), '2026-10-24');
  assert.equal(myanmarToday(Date.parse('2026-10-24T17:30:00Z')), '2026-10-25');
});
test('bilingual phase and leap month labels', () => {
  const full = calendar.get('2023-08-01');
  assert.equal(calendar.monthName(full,'en'), 'Second Waso');
  assert.equal(calendar.lunarText(full,'my'), 'လပြည့်');
  assert.equal(digits(1385,'my'), '၁၃၈၅');
  assert.equal(digits(1385,'en'), '1385');
});
test('upcoming sabbaths are ordered and stop at the upper boundary', () => {
  const days = calendar.upcoming('2026-10-24');
  assert.equal(days.length, 4);
  assert.ok(days.every(d => d.sabbath));
  assert.ok(days.every((d,i) => !i || d.day > days[i-1].day));
  assert.ok(calendar.upcoming('2100-12-31').length <= 1);
});
test('bundled data is byte-identical across platforms', () => {
  const canonical = readFileSync(new URL('../../shared/calendar.json',import.meta.url));
  for (const path of ['../assets/calendar.json','../../android_flutter/assets/calendar.json','../../ios_swift/NayYet/Resources/calendar.json','../../ios_swift/NayYetTests/Fixtures/calendar.json']) {
    assert.deepEqual(readFileSync(new URL(path,import.meta.url)), canonical);
  }
});

test('date search accepts Myanmar digits and rejects impossible dates', async () => {
 const {parseDateQuery}=await import('../calendar.js');
 assert.equal(parseDateQuery('၀၁/၀၁/၂၀၂၆'),'2026-01-01');
 assert.equal(parseDateQuery('2024-02-29'),'2024-02-29');
 assert.throws(()=>parseDateQuery('31/02/2026'));
 assert.throws(()=>parseDateQuery('2026-1-01'));
});
test('holidays distinguish public closures and world observances',()=>{
 assert.ok(data.events['2026-01-01'].some(e=>e.kind==='public2026'));
 assert.ok(data.events['2026-10-25'].some(e=>e.kind==='public2026'));
 assert.ok(data.events['2026-03-08'].every(e=>e.kind==='world'));
 assert.ok(!data.events['2027-01-01'].some(e=>e.kind==='public2026'));
 assert.equal(data.events['1920-01-01'],undefined);
});
test('quote rotation changes each day, matches languages and works before epoch',async()=>{
 const {quoteFor}=await import('../calendar.js');
 for(const iso of ['1900-01-01','1969-12-31','2026-10-25','2100-12-30']){
  const next=isoFromDay(dayNumber(iso)+1);
  assert.notEqual(quoteFor(data,iso).my,quoteFor(data,next).my);
  assert.ok(quoteFor(data,iso).en && quoteFor(data,iso).my);
 }
 assert.equal(new Set(data.quotes.map(q=>q.en)).size,31);
});
