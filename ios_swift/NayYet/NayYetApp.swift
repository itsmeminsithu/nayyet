// Copyright 2026 Min SiThu (itsmeminsithu). MIT.
import SwiftUI

@main
struct NayYetApp: App {
    private let store: CalendarStore? = {
        guard let url = Bundle.main.url(forResource: "calendar", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? CalendarStore(data: data)
    }()
    var body: some Scene {
        WindowGroup {
            if let store { ContentView(store: store) }
            else { Text("ပြက္ခဒိန်ဖိုင်ကို ဖတ်မရပါ။\nCould not load calendar data.").padding() }
        }
    }
}
