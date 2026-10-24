"""Attach bilingual observances and a deterministic daily quote rotation."""
from datetime import date, timedelta
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
SOURCE='https://www.mofa.gov.mm/about-myanmar/public-holidays/'

def enrich(data):
    events={}
    def add(d,my,en,kind):
        events.setdefault(d.isoformat(),[]).append({'my':my,'en':en,'kind':kind})
    fixed=[('01-01','နှစ်သစ်ကူးနေ့','New Year’s Day','world'),('01-04','လွတ်လပ်ရေးနေ့','Independence Day','recurring'),('02-12','ပြည်ထောင်စုနေ့','Union Day','recurring'),('03-02','တောင်သူလယ်သမားနေ့','Peasants’ Day','recurring'),('03-08','အပြည်ပြည်ဆိုင်ရာ အမျိုးသမီးများနေ့','International Women’s Day','world'),('03-22','ကမ္ဘာ့ရေနေ့','World Water Day','world'),('03-27','တပ်မတော်နေ့','Armed Forces Day','recurring'),('05-01','အလုပ်သမားနေ့','Labour Day','recurring'),('06-05','ကမ္ဘာ့ပတ်ဝန်းကျင်ထိန်းသိမ်းရေးနေ့','World Environment Day','world'),('07-19','အာဇာနည်နေ့','Martyrs’ Day','recurring'),('09-21','အပြည်ပြည်ဆိုင်ရာ ငြိမ်းချမ်းရေးနေ့','International Day of Peace','world'),('10-24','ကုလသမဂ္ဂနေ့','United Nations Day','world'),('12-10','လူ့အခွင့်အရေးနေ့','Human Rights Day','world'),('12-25','ခရစ္စမတ်နေ့','Christmas Day','world')]
    # Recurring modern observances start in 2026; do not retroactively assert historical holidays.
    for year in range(2026,2101):
        for md,my,en,kind in fixed:
            if year==2026 and md in ['01-01','01-04','02-12','03-02','03-27','05-01','07-19','12-25']:kind='public2026'
            add(date.fromisoformat(f'{year}-{md}'),my,en,kind)
    from build_calendar import convert
    d=date(2026,1,1)
    while d<=date(2100,12,31):
        y,m,day,typ,length=convert(d)
        if y!=convert(d-timedelta(days=1))[0]:add(d,'မြန်မာနှစ်သစ်ကူးနေ့','Myanmar New Year','calculated')
        for month,ld,my,en in [(2,15,'ကဆုန်လပြည့်နေ့','Kason full moon'),(4,15,'ဝါဆိုလပြည့်နေ့','Waso full moon'),(7,15,'သီတင်းကျွတ်လပြည့်နေ့','Thadingyut full moon'),(8,15,'တန်ဆောင်မုန်းလပြည့်နေ့','Tazaungmon full moon'),(8,25,'အမျိုးသားနေ့','National Day'),(10,1,'ကရင်နှစ်သစ်ကူးနေ့','Karen New Year')]:
            if m==month and day==ld:add(d,my,en,'calculated')
        d+=timedelta(days=1)
    for start,end,my,en in [('2026-04-11','2026-04-19','သင်္ကြန်ရုံးပိတ်ရက်','Thingyan public holiday'),('2026-10-25','2026-10-27','သီတင်းကျွတ်ရုံးပိတ်ရက်','Thadingyut public holiday'),('2026-11-23','2026-11-24','တန်ဆောင်တိုင်ရုံးပိတ်ရက်','Tazaungdaing public holiday')]:
        d=date.fromisoformat(start)
        while d<=date.fromisoformat(end):add(d,my,en,'public2026');d+=timedelta(days=1)
    events['2026-12-04'][0]['kind']='public2026'
    add(date(2026,7,29),'ဝါဆိုရုံးပိတ်ရက်','Waso public holiday','public2026')
    quotes=[
('သေးငယ်တဲ့ ခြေလှမ်းတစ်လှမ်းလည်း ရှေ့ကိုရောက်စေတယ်။','A small step still takes you forward.'),
('ဒီနေ့ လုပ်နိုင်တာတစ်ခုကို အာရုံစိုက်ပါ။','Give your attention to one thing you can do today.'),
('အနားယူတာလည်း ခရီးဆက်ဖို့ ပြင်ဆင်တာပါ။','Rest is part of getting ready to continue.'),
('မနေ့ကထက် နည်းနည်းပိုနားလည်လာရင် တိုးတက်နေတာပါ။','Understanding a little more than yesterday is progress.'),
('ကိုယ့်အရှိန်နဲ့ ကိုယ်သွားလို့ရပါတယ်။','You are allowed to move at your own pace.'),
('နားထောင်ပေးခြင်းကလည်း ကြင်နာမှုတစ်မျိုးပါ။','Listening is one way to be kind.'),
('မပြီးသေးတာဟာ မဖြစ်နိုင်တာ မဟုတ်ပါ။','Unfinished does not mean impossible.'),
('မေးခွန်းကောင်းတစ်ခုက သင်ယူမှုကို စတင်ပေးတယ်။','A good question opens a path to learning.'),
('ဒီနေ့ရဲ့ အချိန်နည်းနည်းကို ကိုယ့်အတွက် ချန်ထားပါ။','Keep a little of today for yourself.'),
('အမှားတစ်ခုက နောက်ခြေလှမ်းအတွက် သင်ခန်းစာဖြစ်နိုင်တယ်။','A mistake can teach you how to take the next step.'),
('ကျေးဇူးတင်စရာ အသေးအဖွဲတွေကို သတိပြုပါ။','Notice the small things you are grateful for.'),
('အရာရာကို ဒီနေ့တစ်ရက်တည်း ဖြေရှင်းစရာမလိုပါ။','You do not have to solve everything in one day.'),
('မိမိကိုယ်ကို ပေးထားတဲ့ ကတိလေးတစ်ခုကို တည်ပါ။','Keep one small promise you made to yourself.'),
('သိချင်စိတ်ကို နေရာပေးပါ။','Make room for curiosity.'),
('လိုအပ်တဲ့အချိန်မှာ အကူအညီတောင်းတာ ကောင်းပါတယ်။','It is okay to ask for help when you need it.'),
('ကောင်းတဲ့ အလေ့အကျင့်တွေက နေ့စဉ်လုပ်ရပ်လေးတွေကနေ စတယ်။','Good habits begin with small daily actions.'),
('အလျင်မလိုဘဲ သေချာလုပ်လို့ရပါတယ်။','You can take your time and do it carefully.'),
('ကိုယ့်တိုးတက်မှုကို ကိုယ်သတိထားကြည့်ပါ။','Take a moment to notice your own progress.'),
('အတွေးသစ်တစ်ခုကို ချရေးထားပါ။','Write down a new thought before it slips away.'),
('တစ်စုံတစ်ယောက်ရဲ့နေ့ကို ပိုကောင်းအောင် လုပ်ပေးနိုင်ပါတယ်။','You can make someone’s day a little better.'),
('မသိသေးတာကို ဝန်ခံခြင်းက သင်ယူဖို့ အစပါ။','Admitting what you do not know is a beginning.'),
('စတင်ဖို့ အရာအားလုံး အဆင်သင့်ဖြစ်စရာ မလိုပါ။','Everything does not have to be ready before you begin.'),
('အာရုံစိုက်ပြီး လုပ်တဲ့ မိနစ်အနည်းငယ်ကလည်း တန်ဖိုးရှိတယ်။','A few focused minutes can be worthwhile.'),
('ပတ်ဝန်းကျင်က အသံလေးတွေကို ခဏနားထောင်ကြည့်ပါ။','Pause and listen to the sounds around you.'),
('ပြီးမြောက်ခဲ့တာလေးတွေကို အသိအမှတ်ပြုပါ။','Give yourself credit for what you have finished.'),
('အလေ့အကျင့်ဟောင်းကို ပြောင်းဖို့ အခွင့်အရေးရှိနေတယ်။','There is room to change an old habit.'),
('တစ်နေ့တာထဲမှာ ပျော်ရွှင်စရာလေးတစ်ခု ရှာပါ။','Find one small thing to enjoy in your day.'),
('အလုပ်များနေရင်တောင် အသက်ကို ဖြည်းဖြည်းရှူပါ။','Even on a busy day, take a slow breath.'),
('ရည်မှန်းချက်ကြီးကို အလုပ်သေးသေးလေးတွေ ခွဲလုပ်ပါ။','Break a large goal into smaller tasks.'),
('ကောင်းသောစကားတစ်ခွန်းက အားဖြစ်စေနိုင်တယ်။','A thoughtful word can give someone strength.'),
('ပြန်စနိုင်ဖို့ နောက်တစ်ရက်ကို စောင့်စရာမလိုပါ။','You do not need to wait for another day to begin again.')]
    data['themes']=json.loads((ROOT/'shared/themes.json').read_text(encoding='utf-8'))
    data['events']=events
    data['quotes']=[{'my':my,'en':en} for my,en in quotes]
    data['holidayMeta']={'checked':'2026-10-25','officialYear':2026,'source':SOURCE,'coverage':'Selected holidays, not exhaustive. No historical holiday data before 2026. Future dates are recurring or calculated, not official closures.'}
    return data
