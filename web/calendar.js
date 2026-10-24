// Copyright 2026 Min SiThu (itsmeminsithu). MIT.
export const DAY=86400000;
export const MONTHS={my:['ပထမဝါဆို','တန်ခူး','ကဆုန်','နယုန်','ဝါဆို','ဝါခေါင်','တော်သလင်း','သီတင်းကျွတ်','တန်ဆောင်မုန်း','နတ်တော်','ပြာသို','တပို့တွဲ','တပေါင်း','နှောင်းတန်ခူး','နှောင်းကဆုန်'],en:['First Waso','Tagu','Kason','Nayon','Waso','Wagaung','Tawthalin','Thadingyut','Tazaungmon','Nadaw','Pyatho','Tabodwe','Tabaung','Late Tagu','Late Kason']};
export const PHASES={my:['လဆန်း','လပြည့်','လဆုတ်','လကွယ်'],en:['Waxing','Full moon','Waning','New moon']};
export function digits(value,lang){return lang==='my'?String(value).replace(/[0-9]/g,d=>'၀၁၂၃၄၅၆၇၈၉'[Number(d)]):String(value)}
export function dayNumber(iso){if(!/^\d{4}-\d{2}-\d{2}$/.test(iso))throw new Error('Invalid date');const t=Date.parse(iso+'T00:00:00Z');if(!Number.isFinite(t)||new Date(t).toISOString().slice(0,10)!==iso)throw new Error('Invalid date');return t/DAY}
export function isoFromDay(day){return new Date(day*DAY).toISOString().slice(0,10)}
export function myanmarToday(now=Date.now()){return new Date(now+23400000).toISOString().slice(0,10)}
export class Calendar{
 constructor(data){this.data=data;this.from=dayNumber(data.from);this.to=dayNumber(data.to)}
 get(iso){const day=dayNumber(iso);if(day<this.from||day>this.to)throw new RangeError('Supported dates: 1900–2100');const rows=this.data.segments;let lo=0,hi=rows.length-1;while(lo<hi){const mid=Math.ceil((lo+hi)/2);if(rows[mid][0]<=day)lo=mid;else hi=mid-1}const [start,year,month,first,type,length]=rows[lo],md=first+day-start;const phase=md===15?1:md===length?3:md<15?0:2;return{iso,day,year,month,md,type,length,phase,fortnight:md>15?md-15:md,sabbath:[8,15,23,length].includes(md),eve:[7,14,22,length-1].includes(md)}}
 monthName(date,lang){return date.month===4&&date.type>0?(lang==='my'?'ဒုတိယဝါဆို':'Second Waso'):MONTHS[lang][date.month]}
 lunarText(date,lang){const phase=PHASES[lang][date.phase];return date.phase===1||date.phase===3?phase:phase+' '+digits(date.fortnight,lang)+(lang==='my'?' ရက်':'')}
 fullText(date,lang){return lang==='my'?digits(date.year,lang)+' ခု၊ '+this.monthName(date,lang)+' '+this.lunarText(date,lang):this.monthName(date,lang)+' · '+this.lunarText(date,lang)+' · '+date.year+' ME'}
 upcoming(iso,count=4){let n=dayNumber(iso),result=[];while(n<=this.to&&result.length<count){const d=this.get(isoFromDay(n));if(d.sabbath)result.push(d);n++}return result}
}
export function parseDateQuery(text){
 const s=text.trim().replace(/[၀-၉]/g,c=>String('၀၁၂၃၄၅၆၇၈၉'.indexOf(c)));
 let iso=s;
 if(/^\d{1,2}\/\d{1,2}\/\d{4}$/.test(s)){const[d,m,y]=s.split('/');iso=`${y}-${m.padStart(2,'0')}-${d.padStart(2,'0')}`;}
 dayNumber(iso);return iso;
}
export const eventKinds={my:{public2026:'၂၀၂၆ ရုံးပိတ်ရက်',recurring:'နှစ်စဉ် အထိမ်းအမှတ်နေ့',calculated:'ပြက္ခဒိန်အရတွက်ထားသောနေ့',world:'နိုင်ငံတကာ အထိမ်းအမှတ်နေ့'},en:{public2026:'2026 public holiday',recurring:'Annual observance',calculated:'Calculated calendar date',world:'International observance'}};
export function quoteFor(data,iso){const index=((dayNumber(iso)%data.quotes.length)+data.quotes.length)%data.quotes.length;return data.quotes[index];}
