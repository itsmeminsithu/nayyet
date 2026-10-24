// Copyright 2026 Min SiThu (itsmeminsithu). MIT.
import Foundation

struct MyanmarDay: Identifiable {
    let date: Date
    let year: Int
    let month: Int
    let day: Int
    let yearType: Int
    let length: Int
    var id: Date { date }
    var phase: Int { day == 15 ? 1 : day == length ? 3 : day < 15 ? 0 : 2 }
    var fortnight: Int { day > 15 ? day - 15 : day }
    var sabbath: Bool { [8, 15, 23, length].contains(day) }
    var eve: Bool { [7, 14, 22, length - 1].contains(day) }
}

struct CalendarStore {
    struct Table: Decodable { let from: String; let to: String; let segments: [[Int]]; let events: [String: [Observance]]; let quotes: [DailyQuote]; let themes: [MonthTheme] }
    enum Failure: Error { case invalidData, outsideRange }
    static let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()
    static let first = date(1900, 1, 1)
    static let last = date(2100, 12, 31)
    struct Observance: Decodable { let my: String; let en: String; let kind: String }
    struct DailyQuote: Decodable { let my: String; let en: String }
    struct MonthTheme: Decodable { let month: Int; let en: String; let my: String; let accent: String; let paper: String; let file: String }
    private let themes: [MonthTheme]
    func theme(_ date: Date) -> MonthTheme { themes[Self.utc.component(.month,from:date)-1] }
    private let eventTable: [String: [Observance]]
    private let quotes: [DailyQuote]
    func events(_ date: Date) -> [Observance] {
        let c=Self.utc.dateComponents([.year,.month,.day], from:date)
        return eventTable[String(format:"%04d-%02d-%02d",c.year!,c.month!,c.day!)] ?? []
    }
    func quote(_ date: Date, _ mm: Bool) -> String {
        let index=((Self.dayNumber(date) % quotes.count) + quotes.count) % quotes.count
        return mm ? quotes[index].my : quotes[index].en
    }
    static func kind(_ key: String, _ mm: Bool) -> String {
        let labels=mm ? ["public2026":"၂၀၂၆ ရုံးပိတ်ရက်","recurring":"နှစ်စဉ် အထိမ်းအမှတ်နေ့","calculated":"ပြက္ခဒိန်အရတွက်ထားသောနေ့","world":"နိုင်ငံတကာ အထိမ်းအမှတ်နေ့"] : ["public2026":"2026 public holiday","recurring":"Annual observance","calculated":"Calculated calendar date","world":"International observance"]
        return labels[key] ?? key
    }
    static func parseQuery(_ input: String) -> Date? {
        var s=input.trimmingCharacters(in:.whitespacesAndNewlines)
        for (n,c) in Array("၀၁၂၃၄၅၆၇၈၉").enumerated(){s=s.replacingOccurrences(of:String(c),with:String(n))}
        let slash=s.split(separator:"/");if slash.count==3{s="\(slash[2])-\(slash[1])-\(slash[0])"}
        guard s.range(of:"^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$",options:.regularExpression) != nil else{return nil}
        let p=s.split(separator:"-").compactMap{Int($0)}
        guard p.count==3, (1900...2100).contains(p[0]), (1...12).contains(p[1]), (1...31).contains(p[2]) else{return nil}
        let d=date(p[0],p[1],p[2]);guard utc.component(.day,from:d)==p[2] else{return nil};return d
    }
    private let rows: [[Int]]
    init(data: Data) throws {
        let table = try JSONDecoder().decode(Table.self, from: data)
        guard table.from == "1900-01-01", table.to == "2100-12-31",
              !table.quotes.isEmpty, !table.segments.isEmpty, table.segments.allSatisfy({ $0.count == 6 }) else {
            throw Failure.invalidData
        }
        rows = table.segments
        eventTable = table.events
        quotes = table.quotes
        themes = table.themes
    }
    static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        utc.date(from: DateComponents(year: year, month: month, day: day))!
    }
    static func today(now: Date = Date()) -> Date {
        utc.startOfDay(for: now.addingTimeInterval(23400))
    }
    static func clamp(_ date: Date) -> Date { min(max(date, first), last) }
    static func dayNumber(_ date: Date) -> Int { Int(floor(date.timeIntervalSince1970 / 86400)) }
    static func monthStart(_ date: Date) -> Date {
        self.date(utc.component(.year, from: date), utc.component(.month, from: date), 1)
    }
    func get(_ date: Date) throws -> MyanmarDay {
        let day = Self.dayNumber(date)
        guard day >= Self.dayNumber(Self.first), day <= Self.dayNumber(Self.last) else {
            throw Failure.outsideRange
        }
        var low = 0, high = rows.count - 1
        while low < high {
            let middle = (low + high + 1) / 2
            if rows[middle][0] <= day { low = middle } else { high = middle - 1 }
        }
        let row = rows[low]
        return MyanmarDay(date: Self.utc.startOfDay(for: date), year: row[1], month: row[2],
                          day: row[3] + day - row[0], yearType: row[4], length: row[5])
    }
    func upcoming(_ date: Date) -> [MyanmarDay] {
        var result: [MyanmarDay] = [], cursor = date
        while cursor <= Self.last && result.count < 4 {
            if let day = try? get(cursor), day.sabbath { result.append(day) }
            cursor = cursor.addingTimeInterval(86400)
        }
        return result
    }
}

enum CalendarText {
    static let monthsMM = ["ပထမဝါဆို", "တန်ခူး", "ကဆုန်", "နယုန်", "ဝါဆို", "ဝါခေါင်", "တော်သလင်း", "သီတင်းကျွတ်", "တန်ဆောင်မုန်း", "နတ်တော်", "ပြာသို", "တပို့တွဲ", "တပေါင်း", "နှောင်းတန်ခူး", "နှောင်းကဆုန်"]
    static let monthsEN = ["First Waso", "Tagu", "Kason", "Nayon", "Waso", "Wagaung", "Tawthalin", "Thadingyut", "Tazaungmon", "Nadaw", "Pyatho", "Tabodwe", "Tabaung", "Late Tagu", "Late Kason"]
    static func number(_ value: Int, _ mm: Bool) -> String {
        let digits = Array("၀၁၂၃၄၅၆၇၈၉")
        return mm ? String(String(value).map { $0.wholeNumberValue.map { digits[$0] } ?? $0 }) : String(value)
    }
    static func month(_ day: MyanmarDay, _ mm: Bool) -> String {
        if day.month == 4 && day.yearType > 0 { return mm ? "ဒုတိယဝါဆို" : "Second Waso" }
        return (mm ? monthsMM : monthsEN)[day.month]
    }
    static func lunar(_ day: MyanmarDay, _ mm: Bool) -> String {
        let phase = (mm ? ["လဆန်း", "လပြည့်", "လဆုတ်", "လကွယ်"] : ["Waxing", "Full moon", "Waning", "New moon"])[day.phase]
        return day.phase == 1 || day.phase == 3 ? phase : phase + " " + number(day.fortnight, mm) + (mm ? " ရက်" : "")
    }
    static func gregorian(_ date: Date, _ mm: Bool) -> String {
        let names = mm ? ["ဇန်နဝါရီ", "ဖေဖော်ဝါရီ", "မတ်", "ဧပြီ", "မေ", "ဇွန်", "ဇူလိုင်", "ဩဂုတ်", "စက်တင်ဘာ", "အောက်တိုဘာ", "နိုဝင်ဘာ", "ဒီဇင်ဘာ"] : ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        return names[CalendarStore.utc.component(.month, from: date) - 1] + " " + number(CalendarStore.utc.component(.year, from: date), mm)
    }
}
