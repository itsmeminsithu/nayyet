import{exportQuote}from'./quote-export.js';
import{Calendar,digits,myanmarToday,isoFromDay,DAY,parseDateQuery,eventKinds,quoteFor}from'./calendar.js';
const $=id=>document.getElementById(id);
const strings={my:{today:'ယနေ့',eyebrow:'ကိုယ့်နေ့ရက်တွေနဲ့ ပိုနီးစပ်ဖို့',headline:'နေ့တိုင်းမှာ အဓိပ္ပါယ်ရှိတယ်။',jump:'ရက်စွဲရွေးရန်',sabbath:'ဥပုသ်နေ့',eve:'အဖိတ်နေ့',ordinary:'သာမန်နေ့',selected:'ရွေးထားသောနေ့',year:'မြန်မာသက္ကရာဇ်',type:'နှစ်အမျိုးအစား',types:['ဝါမထပ်နှစ်','ဝါငယ်ထပ်နှစ်','ဝါကြီးထပ်နှစ်'],upcoming:'လာမည့် ဥပုသ်နေ့များ',from:'ရွေးထားသောနေ့မှ စ၍',about:'ဒီပြက္ခဒိန်အကြောင်း',copy:'၁၉၀၀ မှ ၂၁၀၀ အထိ မြန်မာရက်စွဲတွေကို ကြည့်နိုင်ပါတယ်။ “ယနေ့” ကို မြန်မာစံတော်ချိန် (UTC+၆:၃၀) နဲ့ သတ်မှတ်ထားပါတယ်။ လပုံက ပြက္ခဒိန်အရ လဆန်း/လဆုတ်ကို ပြတာဖြစ်ပြီး ကောင်းကင်မှာ မြင်ရတဲ့လကို တိုင်းတာထားတာ မဟုတ်ပါ။ ရွေးချယ်ထားသော ၂၀၂၆ ရုံးပိတ်ရက်တွေ ပါဝင်ပါတယ်။ အခြားနှစ်များအတွက် ရုံးပိတ်ရက် အတည်ပြုစာရင်း မဟုတ်ပါ။',contact:'ဆက်သွယ်ရန်',skip:'ပြက္ခဒိန်သို့',previous:'ယခင်လ',next:'နောက်လ',error:'ရက်စွဲမှားနေပါတယ်။ ၁၉၀၀ မှ ၂၁၀၀ အတွင်း ရွေးပါ။',loadError:'ပြက္ခဒိန်ဖိုင်ကို ဖတ်မရပါ။ Start-Web.command နဲ့ server ဖွင့်ပြီး ပြန်စမ်းပါ။'},en:{today:'Today',eyebrow:'A LITTLE CLOSER TO YOUR DAYS',headline:'Every day has a place.',jump:'Go to a date',sabbath:'Sabbath',eve:'Sabbath eve',ordinary:'Ordinary day',selected:'SELECTED DAY',year:'Myanmar year',type:'Year type',types:['Common year','Little intercalary year','Big intercalary year'],upcoming:'The next quiet days',from:'Sabbaths from your selected date',about:'About this calendar',copy:'Explore Myanmar dates from 1900 to 2100. Today follows Myanmar Standard Time (UTC+06:30). The moon artwork represents the calendar phase, not an observed astronomical moon. Selected 2026 public holidays are included. Other years show recurring or calculated observances, not confirmed closures.',contact:'Contact',skip:'Skip to calendar',previous:'Previous month',next:'Next month',error:'Choose a valid date between 1900 and 2100.',loadError:'Calendar data could not load. Start the local server using Start-Web.command and try again.'}};
let lang='my';try{lang=localStorage.getItem('nayyet-language')==='en'?'en':'my'}catch{}
let selected=myanmarToday();if(selected<'1900-01-01'||selected>'2100-12-31')selected='2026-10-25';let view=selected.slice(0,7),calendar;
function element(tag,cls,text){const e=document.createElement(tag);if(cls)e.className=cls;if(text!==undefined)e.textContent=text;return e}
function format(iso,options){
 const date=new Date(iso+'T12:00:00Z');
 if(lang==='en')return new Intl.DateTimeFormat('en-GB',{timeZone:'UTC',...options}).format(date);
 const months=['ဇန်နဝါရီ','ဖေဖော်ဝါရီ','မတ်','ဧပြီ','မေ','ဇွန်','ဇူလိုင်','ဩဂုတ်','စက်တင်ဘာ','အောက်တိုဘာ','နိုဝင်ဘာ','ဒီဇင်ဘာ'];
 const weekdays=['တနင်္ဂနွေ','တနင်္လာ','အင်္ဂါ','ဗုဒ္ဓဟူး','ကြာသပတေး','သောကြာ','စနေ'];
 const shortDays=['နွေ','လာ','ဂါ','ဟူး','ကြာ','သော','နေ'];
 const month=months[date.getUTCMonth()],day=digits(date.getUTCDate(),lang),year=digits(date.getUTCFullYear(),lang);
 if(options.dateStyle)return weekdays[date.getUTCDay()]+'၊ '+day+' '+month+' '+year;
 if(options.weekday)return (options.weekday==='short'?shortDays:weekdays)[date.getUTCDay()];
 return options.day?day+' '+month:month+' '+year;
}
function choose(iso){try{calendar.get(iso);selected=iso;view=iso.slice(0,7);$('error').hidden=true;render()}catch{$('error').textContent=strings[lang].error;$('error').hidden=false}}
function shift(delta){const [y,m]=view.split('-').map(Number),d=new Date(Date.UTC(y,m-1+delta,1)),iso=d.toISOString().slice(0,10);if(iso<'1900-01-01'||iso>'2100-12-31')return;view=iso.slice(0,7);render()}
function render(){const t=strings[lang];
 const season=calendar.data.themes[Number(view.slice(5,7))-1];
 document.documentElement.style.setProperty('--plum',season.accent);
 document.documentElement.style.setProperty('--paper',season.paper);
 document.documentElement.style.setProperty('--lavender',season.paper);
 $('season-banner').style.backgroundImage=`linear-gradient(90deg,${season.top}dd,${season.top}11),url('assets/themes/${season.file}')`;
 $('season-kicker').textContent=format(view+'-01',{month:'long',year:'numeric'});
 $('season-title').textContent=season[lang];
 $('quote-theme').options[0].textContent=lang==='my'?'လအလိုက် နောက်ခံ':'Monthly theme';

 $('search-label').textContent=lang==='my'?'ရက်စွဲရှာရန် / အတိတ်ရက်စွဲ':'Search a date / look back';
 $('search-button').textContent=lang==='my'?'ရှာရန်':'Search';
 $('day-back').setAttribute('aria-label',lang==='my'?'ယခင်ရက်':'Previous day');$('day-forward').setAttribute('aria-label',lang==='my'?'နောက်ရက်':'Next day');
 $('day-back').disabled=selected==='1900-01-01';$('day-forward').disabled=selected==='2100-12-31';
 $('quote-caption').textContent=(lang==='my'?'ရွေးထားသောနေ့အတွက် စာတို · ':'A thought for your selected day · ')+format(selected,{dateStyle:'full'});
 $('daily-quote').textContent=quoteFor(calendar.data,selected)[lang];
 const quoteSeason=calendar.data.themes[Number(selected.slice(5,7))-1];
 $('quote-panel').style.backgroundImage=`linear-gradient(90deg,#0009,#0005),url('assets/themes/${quoteSeason.file}')`;
 $('quote-panel').style.backgroundSize='cover';
 $('quote-panel').style.backgroundPosition='center';
 $('theme-label').textContent=lang==='my'?'နောက်ခံ':'Background';$('save-quote').textContent=lang==='my'?'PNG သိမ်းရန်':'Save PNG';$('share-quote').textContent=lang==='my'?'မျှဝေရန်':'Share';
 $('export-status').textContent='';
document.documentElement.lang=lang;for(const[id,key]of[['today','today'],['eyebrow','eyebrow'],['headline','headline'],['jump-label','jump'],['sabbath-legend','sabbath'],['upcoming-title','upcoming'],['upcoming-subtitle','from'],['about-title','about'],['about-copy','copy'],['contact','contact'],['skip','skip']])$(id).textContent=t[key];$('language').textContent=lang==='my'?'English':'မြန်မာ';$('prev').setAttribute('aria-label',t.previous);$('next').setAttribute('aria-label',t.next);$('prev').disabled=view==='1900-01';$('next').disabled=view==='2100-12';$('jump').value=selected;$('range-legend').textContent=digits('1900 – 2100',lang);$('month-title').textContent=format(view+'-01',{month:'long',year:'numeric'});
 const[y,m]=view.split('-').map(Number),count=new Date(Date.UTC(y,m,0)).getUTCDate(),first=new Date(view+'-01T12:00:00Z').getUTCDay();const lunarMonths=[];for(let n=1;n<=count;n++){const d=calendar.get(view+'-'+String(n).padStart(2,'0')),s=calendar.monthName(d,lang);if(!lunarMonths.includes(s))lunarMonths.push(s)}$('lunar-range').textContent=lunarMonths.join(' / ');
 $('weekdays').replaceChildren();for(let n=0;n<7;n++)$('weekdays').append(element('span','',format('2024-01-'+String(7+n).padStart(2,'0'),{weekday:'short'})));
 $('days').replaceChildren();for(let n=0;n<first;n++)$('days').append(element('span','empty-day'));
 for(let n=1;n<=count;n++){const iso=view+'-'+String(n).padStart(2,'0'),d=calendar.get(iso),button=element('button','day'+(iso===selected?' selected':'')+(iso===myanmarToday()?' is-today':''));button.type='button';const events=calendar.data.events[iso]||[];if(events.length){button.classList.add('has-event');button.title=events.map(e=>e[lang]).join(' · ');button.append(element('span','event-marker','◆'));}button.setAttribute('aria-label',format(iso,{dateStyle:'full'})+' · '+calendar.fullText(d,lang)+(d.sabbath?' · '+t.sabbath:''));button.setAttribute('aria-pressed',iso===selected?'true':'false');button.append(element('b','',digits(n,lang)),element('small','',calendar.lunarText(d,lang)));if(d.sabbath)button.append(element('i','dot'));button.onclick=()=>choose(iso);$('days').append(button)}
 const d=calendar.get(selected),detail=$('details');detail.replaceChildren();const moon=element('div','moon-scene phase-'+d.phase);moon.setAttribute('aria-hidden','true');moon.append(element('div','moon'),element('span','orbit-line'));detail.append(element('p','eyebrow',t.selected),moon,element('p','selected-weekday',format(selected,{weekday:'long'})),element('div','selected-number',digits(Number(selected.slice(-2)),lang)),element('p','selected-gregorian',format(selected,{month:'long',year:'numeric'})),element('h3','lunar-title',calendar.monthName(d,lang)+' '+calendar.lunarText(d,lang)),element('span','badge',d.sabbath?t.sabbath:d.eve?t.eve:t.ordinary));const dl=element('dl','facts');for(const[label,value]of[[t.year,digits(d.year,lang)],[t.type,t.types[d.type]]]){const row=element('div');row.append(element('dt','',label),element('dd','',value));dl.append(row)}detail.append(dl);const events=calendar.data.events[selected]||[];for(const e of events){const block=element('div','holiday');block.append(element('b','',e[lang]),element('small','',eventKinds[lang][e.kind]));detail.append(block)}if(!events.length)detail.append(element('p','holiday-note',lang==='my'?'ဤရက်အတွက် အထိမ်းအမှတ်နေ့စာရင်း မရှိပါ။':'No observances listed for this date.'));if(Number(selected.slice(0,4))!==2026)detail.append(element('p','holiday-note',lang==='my'?'ဤနှစ်အတွက် ရုံးပိတ်ရက် အတည်ပြုစာရင်း မပါဝင်ပါ။':'No confirmed public-holiday schedule for this year.'));

 $('upcoming-list').replaceChildren();for(const upcoming of calendar.upcoming(selected)){const button=element('button','upcoming-card');button.append(element('span','mini-moon phase-'+upcoming.phase),element('b','',format(upcoming.iso,{day:'numeric',month:'short'})),element('span','',calendar.monthName(upcoming,lang)),element('small','',calendar.lunarText(upcoming,lang)));button.onclick=()=>choose(upcoming.iso);$('upcoming-list').append(button)}
}
$('today').onclick=()=>choose(myanmarToday());$('prev').onclick=()=>shift(-1);$('next').onclick=()=>shift(1);$('jump').onchange=e=>choose(e.target.value);$('language').onclick=()=>{lang=lang==='my'?'en':'my';try{localStorage.setItem('nayyet-language',lang)}catch{}if(calendar)render()};
try{const response=await fetch('./assets/calendar.json');if(!response.ok)throw new Error('data');calendar=new Calendar(await response.json());render();if('serviceWorker'in navigator)navigator.serviceWorker.register('./sw.js').catch(()=>{})}catch{$('error').textContent=strings[lang].loadError;$('error').hidden=false}

$('date-search').onsubmit=e=>{e.preventDefault();try{choose(parseDateQuery($('search-input').value))}catch{$('error').hidden=false;$('error').textContent=strings[lang].error}};
for(const[id,delta]of[['day-back',-1],['day-forward',1]])$(id).onclick=()=>choose(isoFromDay(Date.parse(selected+'T00:00:00Z')/DAY+delta));
async function saveQuote(share){if(!calendar)return;const buttons=[$('save-quote'),$('share-quote')];buttons.forEach(b=>b.disabled=true);try{const result=await exportQuote({text:quoteFor(calendar.data,selected)[lang],date:format(selected,{dateStyle:'full'}),iso:selected,lang,theme:$('quote-theme').value,monthlyTheme:calendar.data.themes[Number(selected.slice(5,7))-1],share});$('export-status').textContent=result==='cancelled'?(lang==='my'?'မျှဝေမှုကို ပယ်ဖျက်ခဲ့သည်။':'Sharing cancelled.'):(lang==='my'?'ပုံအသင့်ဖြစ်ပါပြီ။':'Your image is ready.')}catch{$('export-status').textContent=lang==='my'?'ပုံထုတ်မရပါ။ ပြန်စမ်းပါ။':'Could not export. Please try again.'}finally{buttons.forEach(b=>b.disabled=false)}}
$('save-quote').onclick=()=>saveQuote(false);$('share-quote').onclick=()=>saveQuote(true);
