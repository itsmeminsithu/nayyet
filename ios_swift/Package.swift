// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "NayYetCalendar",
    products: [.library(name: "CalendarCore", targets: ["CalendarCore"])],
    targets: [
        .target(name: "CalendarCore", path: "NayYet", exclude: ["ContentView.swift", "NayYetApp.swift", "QuoteExportView.swift", "Info.plist", "Resources", "Assets.xcassets"], sources: ["CalendarStore.swift"]),
        .testTarget(name: "CalendarCoreTests", dependencies: ["CalendarCore"], path: "NayYetTests", resources: [.copy("Fixtures")])
    ]
)
