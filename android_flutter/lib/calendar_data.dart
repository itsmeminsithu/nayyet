// Copyright 2026 Min SiThu (itsmeminsithu). MIT.
class MyanmarDay {
  final DateTime date;
  final int year, month, day, yearType, monthLength;
  const MyanmarDay(this.date,this.year,this.month,this.day,this.yearType,this.monthLength);
  int get phase => day==15?1:day==monthLength?3:day<15?0:2;
  int get fortnight => day>15?day-15:day;
  bool get sabbath => [8,15,23,monthLength].contains(day);
  bool get eve => [7,14,22,monthLength-1].contains(day);
}
class CalendarData {
  final List<List<int>> segments;
  final Map<String,dynamic> extras;
  CalendarData(Map<String,dynamic> data):extras=data,segments=(data['segments'] as List).map((r)=>(r as List).cast<int>()).toList();
  Map<String,dynamic> theme(DateTime d)=>(extras['themes'][d.month-1] as Map).cast<String,dynamic>();
  List<dynamic> events(DateTime d)=>(extras['events'][civil(d).toIso8601String().substring(0,10)]??[]) as List;
  String quote(DateTime d,bool mm){final list=extras['quotes'] as List;final index=civil(d).difference(epoch).inDays%list.length;return list[index][mm?'my':'en'];}
  static String kind(String k,bool mm)=>(mm?{'public2026':'၂၀၂၆ ရုံးပိတ်ရက်','recurring':'နှစ်စဉ် အထိမ်းအမှတ်နေ့','calculated':'ပြက္ခဒိန်အရတွက်ထားသောနေ့','world':'နိုင်ငံတကာ အထိမ်းအမှတ်နေ့'}:{'public2026':'2026 public holiday','recurring':'Annual observance','calculated':'Calculated calendar date','world':'International observance'})[k]!;
  static DateTime parseQuery(String input){var s=input.trim().replaceAllMapped(RegExp('[၀-၉]'),(m)=>'၀၁၂၃၄၅၆၇၈၉'.indexOf(m[0]!).toString());if(RegExp(r'^\d{1,2}/\d{1,2}/\d{4}$').hasMatch(s)){final p=s.split('/');s='${p[2]}-${p[1].padLeft(2,'0')}-${p[0].padLeft(2,'0')}';}if(!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s))throw FormatException('Date');final d=DateTime.parse('${s}T00:00:00Z');if(d.toIso8601String().substring(0,10)!=s||d.isBefore(first)||d.isAfter(last))throw FormatException('Date');return d;}
  static final first=DateTime.utc(1900,1,1),last=DateTime.utc(2100,12,31),epoch=DateTime.utc(1970,1,1);
  static DateTime civil(DateTime d)=>DateTime.utc(d.year,d.month,d.day);
  static DateTime today(){final d=DateTime.now().toUtc().add(const Duration(hours:6,minutes:30));return civil(d);}
  MyanmarDay get(DateTime input){
    final date=civil(input);
    if(date.isBefore(first)||date.isAfter(last))throw RangeError('Supported dates: 1900–2100');
    final n=date.difference(epoch).inDays;var low=0,high=segments.length-1;
    while(low<high){final mid=(low+high+1)~/2;if(segments[mid][0]<=n){low=mid;}else{high=mid-1;}}
    final r=segments[low];return MyanmarDay(date,r[1],r[2],r[3]+n-r[0],r[4],r[5]);
  }
  List<MyanmarDay> upcoming(DateTime start){final result=<MyanmarDay>[];var d=civil(start);while(!d.isAfter(last)&&result.length<4){final day=get(d);if(day.sabbath)result.add(day);d=d.add(const Duration(days:1));}return result;}
  static String number(Object value,bool mm)=>mm?value.toString().replaceAllMapped(RegExp('[0-9]'),(m)=>'၀၁၂၃၄၅၆၇၈၉'[int.parse(m[0]!)]):value.toString();
  static const monthsMM=['ပထမဝါဆို','တန်ခူး','ကဆုန်','နယုန်','ဝါဆို','ဝါခေါင်','တော်သလင်း','သီတင်းကျွတ်','တန်ဆောင်မုန်း','နတ်တော်','ပြာသို','တပို့တွဲ','တပေါင်း','နှောင်းတန်ခူး','နှောင်းကဆုန်'];
  static const monthsEN=['First Waso','Tagu','Kason','Nayon','Waso','Wagaung','Tawthalin','Thadingyut','Tazaungmon','Nadaw','Pyatho','Tabodwe','Tabaung','Late Tagu','Late Kason'];
  static const phasesMM=['လဆန်း','လပြည့်','လဆုတ်','လကွယ်'],phasesEN=['Waxing','Full moon','Waning','New moon'];
  static String monthName(MyanmarDay d,bool mm)=>d.month==4&&d.yearType>0?(mm?'ဒုတိယဝါဆို':'Second Waso'):(mm?monthsMM:monthsEN)[d.month];
  static String lunar(MyanmarDay d,bool mm){final p=(mm?phasesMM:phasesEN)[d.phase];return d.phase==1||d.phase==3?p:'$p ${number(d.fortnight,mm)}${mm?' ရက်':''}';}
}
