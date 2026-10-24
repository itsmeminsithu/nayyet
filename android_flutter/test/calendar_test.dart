import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:nayyet/calendar_data.dart';
void main(){final data=CalendarData(jsonDecode(File('assets/calendar.json').readAsStringSync()));test('Shared conversion fixtures',(){final rows=jsonDecode(File('../shared/test-vectors.json').readAsStringSync())as List;for(final row in rows){final d=data.get(DateTime.parse(row['date']+'T00:00:00Z'));expect([d.year,d.month,d.day,d.yearType,d.monthLength],row['expected']);}});test('Range boundaries',(){expect(()=>data.get(DateTime.utc(1899,12,31)),throwsRangeError);expect(()=>data.get(DateTime.utc(2101,1,1)),throwsRangeError);});test('Every supported civil day has valid lunar fields',(){for(var date=CalendarData.first;!date.isAfter(CalendarData.last);date=date.add(const Duration(days:1))){final d=data.get(date);expect(d.day,inInclusiveRange(1,d.monthLength));expect(d.phase,inInclusiveRange(0,3));}});}
