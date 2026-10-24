// Copyright 2026 Min SiThu (itsmeminsithu). MIT.
import SwiftUI

struct ContentView: View {
    let store: CalendarStore
    @AppStorage("nayyet.language") private var language = "my"
    @State private var selected = CalendarStore.clamp(CalendarStore.today())
    @State private var month = CalendarStore.monthStart(CalendarStore.clamp(CalendarStore.today()))
    @State private var picking = false
    @State private var search = ""
    @State private var searchError = false
    @State private var sharing = false
    private var plum: Color { Color(themeHex:store.theme(month).accent) }
    private var paper: Color { Color(themeHex:store.theme(month).paper) }
    private var mm: Bool { language == "my" }
    private func t(_ my: String, _ en: String) -> String { mm ? my : en }
    private func number(_ n: Int) -> String { CalendarText.number(n, mm) }
    private func font(_ size: CGFloat) -> Font { .custom(mm ? "Pyidaungsu" : "Outfit-Thin", size: size).weight(.regular) }
    private func choose(_ date: Date) { selected = date; month = CalendarStore.monthStart(date) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ZStack(alignment:.leading) {
                        Image(store.theme(month).file.replacingOccurrences(of:".png",with:"")).resizable().scaledToFill().frame(height:190).clipped().overlay(.black.opacity(0.25))
                        VStack(alignment:.leading,spacing:8){Text(CalendarText.gregorian(month,mm)).font(font(13));Text(mm ? store.theme(month).my : store.theme(month).en).font(font(24))}.foregroundStyle(.white).padding(24)
                    }.frame(height:190).clipShape(RoundedRectangle(cornerRadius:20))

                    HStack { TextField("YYYY-MM-DD / DD/MM/YYYY",text:$search).textFieldStyle(.roundedBorder).onSubmit{searchDate()};Button(t("ရှာရန်","Search")){searchDate()} }
                    Text(t("ရက်စွဲရှာရန် / အတိတ်ရက်စွဲ","Search a date / look back")).font(font(11))
                    if searchError { Text(t("ရက်စွဲမှားနေသည်။ ၁၉၀၀–၂၁၀၀ အတွင်း ရွေးပါ။","Invalid date. Choose 1900–2100.")).foregroundStyle(.red) }
                    HStack { Button(t("← ယခင်ရက်","← Previous day")){choose(selected.addingTimeInterval(-86400))}.disabled(selected<=CalendarStore.first);Spacer();Button(t("နောက်ရက် →","Next day →")){choose(selected.addingTimeInterval(86400))}.disabled(selected>=CalendarStore.last) }
                    VStack(alignment:.leading,spacing:12) { Text(store.quote(selected,mm)).font(font(21));Button(t("မျှဝေရန် / PNG သိမ်းရန်","Share / Save PNG")){sharing=true} }.padding(20).frame(maxWidth:.infinity,alignment:.leading).foregroundStyle(.white).background { GeometryReader { geometry in Image(store.theme(selected).file.replacingOccurrences(of:".png",with:"")).resizable().scaledToFill().frame(width:geometry.size.width,height:geometry.size.height).clipped().overlay(.black.opacity(0.38)) } }.clipShape(RoundedRectangle(cornerRadius:18))

                    Text(t("ကိုယ့်နေ့ရက်တွေနဲ့ ပိုနီးစပ်ဖို့", "A LITTLE CLOSER TO YOUR DAYS"))
                        .font(font(11)).foregroundStyle(.secondary)
                    HStack {
                        Text(t("နေ့တိုင်းမှာ အဓိပ္ပါယ်ရှိတယ်။", "Every day has a place.")).font(font(25))
                        Spacer()
                        Button { picking = true } label: { Image(systemName: "calendar") }
                            .accessibilityLabel(t("ရက်စွဲရွေးရန်", "Choose a date"))
                    }
                    Button(t("ယနေ့", "Today")) { choose(CalendarStore.clamp(CalendarStore.today())) }
                    monthGrid
                    ForEach(Array(store.events(selected).enumerated()), id: \.offset) { _, event in
                        VStack(alignment:.leading){Text(mm ? event.my : event.en);Text(CalendarStore.kind(event.kind,mm)).font(font(11)).foregroundStyle(.secondary)}
                    }
                    if CalendarStore.utc.component(.year,from:selected) != 2026 { Text(t("ဤနှစ်အတွက် ရုံးပိတ်ရက် အတည်ပြုစာရင်း မပါဝင်ပါ။","No confirmed public-holiday schedule for this year.")).font(font(11)) }

                    if let day = try? store.get(selected) { detail(day) }
                    VStack(alignment: .leading, spacing: 5) {
                        Text(t("လာမည့် ဥပုသ်နေ့များ", "Upcoming sabbaths")).font(font(21))
                        Text(t("ရွေးထားသောနေ့မှ စ၍", "From your selected date")).font(font(12)).foregroundStyle(.secondary)
                    }
                    ForEach(store.upcoming(selected)) { day in
                        Button { choose(day.date) } label: {
                            HStack(spacing: 14) {
                                MoonView(phase: day.phase).frame(width: 30, height: 30)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(number(CalendarStore.utc.component(.day, from: day.date))) \(CalendarText.gregorian(day.date, mm))")
                                    Text("\(CalendarText.month(day, mm)) · \(CalendarText.lunar(day, mm))").font(font(12)).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "arrow.up.right").font(.caption)
                            }.contentShape(Rectangle())
                        }.buttonStyle(.plain)
                    }
                    DisclosureGroup(t("ဒီပြက္ခဒိန်အကြောင်း", "About this calendar")) {
                        Text(t("“ယနေ့” ကို မြန်မာစံတော်ချိန် UTC+၆:၃၀ နဲ့ သတ်မှတ်ပါတယ်။ လပုံက ပြက္ခဒိန်အရ လဆန်း/လဆုတ်ကို ပြတာပါ။ ရွေးချယ်ထားသော ၂၀၂၆ ရုံးပိတ်ရက်များ ပါဝင်သည်။ အခြားနှစ်များအတွက် ရုံးပိတ်ရက်အတည်ပြုစာရင်း မဟုတ်ပါ။", "Today follows Myanmar Standard Time (UTC+06:30). Moon artwork represents the calendar phase. Selected 2026 public holidays are included. Other years show recurring or calculated observances.")).font(font(13)).padding(.top, 8)
                    }
                    Text("© 2026 Min SiThu (itsmeminsithu)\nminsithu.org")
                        .font(.custom("Outfit-Thin", size: 12)).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity).multilineTextAlignment(.center)
                }.padding(20).frame(maxWidth: 680).frame(maxWidth: .infinity)
            }
            .background(paper).font(font(16)).tint(plum)
            .navigationTitle("နေ့ရက် — NayYet").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(mm ? "English" : "မြန်မာ") { language = mm ? "en" : "my" }
                        .font(.custom(mm ? "Outfit-Thin" : "Pyidaungsu", size: 15))
                }
            }
            .sheet(isPresented: $sharing) { QuoteExportView(monthlyAsset:store.theme(selected).file.replacingOccurrences(of:".png",with:""),text:store.quote(selected,mm),date:"\(number(CalendarStore.utc.component(.day,from:selected))) \(CalendarText.gregorian(selected,mm))",mm:mm) }
            .sheet(isPresented: $picking) {
                NavigationStack {
                    DatePicker(t("ရက်စွဲရွေးရန်", "Choose a date"), selection: Binding(get: { selected }, set: { choose($0) }), in: CalendarStore.first...CalendarStore.last, displayedComponents: .date)
                        .datePickerStyle(.graphical).padding()
                        .environment(\.timeZone, TimeZone(secondsFromGMT: 0)!)
                        .environment(\.calendar, CalendarStore.utc)
                        .environment(\.locale, Locale(identifier: mm ? "my_MM" : "en_GB"))
                        .toolbar { Button(t("ပြီးပြီ", "Done")) { picking = false } }
                }.presentationDetents([.medium, .large])
            }
        }.preferredColorScheme(.light)
    }

    private func searchDate(){if let date=CalendarStore.parseQuery(search){choose(date);searchError=false}else{searchError=true}}
    private var monthGrid: some View {
        let offset = CalendarStore.utc.component(.weekday, from: month) - 1
        let count = CalendarStore.utc.range(of: .day, in: .month, for: month)!.count
        return VStack(spacing: 12) {
            HStack {
                Text(CalendarText.gregorian(month, mm)).font(font(22))
                Spacer()
                Button { shift(-1) } label: { Image(systemName: "chevron.left").frame(width: 30, height: 32) }
                    .disabled(month <= CalendarStore.first).accessibilityLabel(t("ယခင်လ", "Previous month"))
                Button { shift(1) } label: { Image(systemName: "chevron.right").frame(width: 30, height: 32) }
                    .disabled(month >= CalendarStore.monthStart(CalendarStore.last)).accessibilityLabel(t("နောက်လ", "Next month"))
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 5) {
                ForEach(mm ? ["နွေ", "လာ", "ဂါ", "ဟူး", "ကြာ", "သော", "နေ"] : ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"], id: \.self) { label in
                    Text(label).font(font(11)).foregroundStyle(.secondary)
                }
                ForEach(0..<(offset + count), id: \.self) { index in
                    if index < offset { Color.clear.frame(height: 66) }
                    else { dayCell(month.addingTimeInterval(Double(index - offset) * 86400)) }
                }
            }
            Text("●  " + t("ဥပုသ်နေ့ · ၁၉၀၀–၂၁၀၀", "Sabbath · 1900–2100")).font(font(11)).foregroundStyle(.secondary)
        }.padding(14).background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 22))
    }

    private func shift(_ step: Int) {
        if let date = CalendarStore.utc.date(byAdding: .month, value: step, to: month),
           date >= CalendarStore.first, date <= CalendarStore.last { month = date }
    }
    private func dayCell(_ date: Date) -> some View {
        let day = try? store.get(date)
        let active = CalendarStore.utc.isDate(date, inSameDayAs: selected)
        return Button { choose(date) } label: {
            VStack(spacing: 3) {
                Text(number(CalendarStore.utc.component(.day, from: date))).font(font(19))
                Text(day.map { CalendarText.lunar($0, mm) } ?? "").font(font(8)).lineLimit(1).minimumScaleFactor(0.5)
                if !store.events(date).isEmpty { Image(systemName:"diamond.fill").font(.system(size:5)).foregroundStyle(.orange) }
                Circle().fill(day?.sabbath == true ? Color.orange : Color.clear).frame(width: 4, height: 4)
            }.frame(maxWidth: .infinity).frame(height: 66)
                .foregroundStyle(active ? .white : plum)
                .background(active ? plum : .clear, in: RoundedRectangle(cornerRadius: 11))
                .overlay(RoundedRectangle(cornerRadius: 11).stroke(date == CalendarStore.today() && !active ? plum : .clear))
        }.buttonStyle(.plain)
            .accessibilityLabel("\(number(CalendarStore.utc.component(.day, from: date))) \(CalendarText.gregorian(date, mm)), \(day.map { CalendarText.month($0, mm) + " " + CalendarText.lunar($0, mm) } ?? "")")
            .accessibilityAddTraits(active ? .isSelected : [])
    }
    private func detail(_ day: MyanmarDay) -> some View {
        VStack(spacing: 12) {
            Text(t("ရွေးထားသောနေ့", "SELECTED DAY")).font(font(11))
            MoonView(phase: day.phase).frame(width: 60, height: 60)
            Text(number(CalendarStore.utc.component(.day, from: selected))).font(font(58))
            Text(CalendarText.gregorian(selected, mm)).font(font(14))
            Text("\(CalendarText.month(day, mm)) \(CalendarText.lunar(day, mm))").font(font(21))
            Text(day.sabbath ? t("ဥပုသ်နေ့", "Sabbath") : day.eve ? t("အဖိတ်နေ့", "Sabbath eve") : t("သာမန်နေ့", "Ordinary day"))
            Divider().padding(.vertical, 4)
            Text(t("မြန်မာသက္ကရာဇ်", "Myanmar year") + " · " + number(day.year))
            Text((mm ? ["ဝါမထပ်နှစ်", "ဝါငယ်ထပ်နှစ်", "ဝါကြီးထပ်နှစ်"] : ["Common year", "Little intercalary year", "Big intercalary year"])[day.yearType]).font(font(12))
        }.multilineTextAlignment(.center).frame(maxWidth: .infinity).padding(24)
            .background(Color(red: 0.91, green: 0.88, blue: 0.94), in: RoundedRectangle(cornerRadius: 22))
    }
}

struct MoonView: View {
    let phase: Int
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle().fill(Color(red: 0.84, green: 0.75, blue: 0.65))
                if phase != 1 {
                    Circle().fill(Color(red: 0.46, green: 0.40, blue: 0.52))
                        .offset(x: phase == 0 ? -geometry.size.width * 0.43 : phase == 2 ? geometry.size.width * 0.43 : 0)
                }
            }.clipShape(Circle())
        }.accessibilityHidden(true)
    }
}

extension Color {
    init(themeHex: String) {
        let value=UInt(themeHex.dropFirst(),radix:16) ?? 0x6b527d
        self.init(red:Double((value>>16)&255)/255,green:Double((value>>8)&255)/255,blue:Double(value&255)/255)
    }
}
