# နေ့ရက် — NayYet

မြန်မာရက်စွဲ၊ လဆန်းလဆုတ်နဲ့ ဥပုသ်နေ့တွေကို နေ့စဉ်ကြည့်ဖို့။

A bilingual Myanmar calendar for Android, iOS and the web.

**Developer:** [Min SiThu (itsmeminsithu)](https://minsithu.org/) · [Contact](https://minsithu.org/contact/)

**Live preview:** https://itsmeminsithu.github.io/nayyet/

## ပါဝင်တာတွေ / Included

- Gregorian လပြက္ခဒိန်နဲ့ မြန်မာရက်စွဲကို တွဲကြည့်နိုင်ခြင်း
- မြန်မာသက္ကရာဇ်၊ မြန်မာလ၊ လဆန်း/လပြည့်/လဆုတ်/လကွယ်
- ဥပုသ်နေ့၊ အဖိတ်နေ့နဲ့ နောက်လာမည့် ဥပုသ်နေ့ လေးရက်
- ရက်စွဲရွေးခြင်း၊ လပြောင်းခြင်း၊ ယနေ့သို့ ပြန်သွားခြင်း
- မြန်မာ / English နှစ်ဘာသာ၊ Unicode UTF-8
- Pyidaungsu နဲ့ Google Fonts မှ Outfit ကို project ထဲမှာ ထည့်ထားခြင်း
- ရက်စွဲအပိုင်းအခြား: 1900-01-01 မှ 2100-12-31

No account, API key, database, analytics or backend is needed. Native apps contain their calendar data and fonts. The web app caches files after a successful first visit over HTTPS or localhost; browser cache eviction can remove offline access. Selected 2026 public holidays and recurring international observances are included. See HOLIDAYS.md for coverage and source discrepancies.

## Project folders

| Folder | Implementation |
| --- | --- |
| `web/` | HTML, CSS and JavaScript; no build step |
| `android_flutter/` | Flutter app, Android runner setup script, tests |
| `ios_swift/` | SwiftUI app, Xcode project, Swift Package core tests |
| `shared/` | Canonical calendar data, test vectors and licensed fonts |
| `tools/` | Reproducible Python calendar-data generator |

This download is a **source package**. It does not include an APK, IPA, signing certificate or store release. Web tests and browser checks were performed. Flutter and Xcode builds have not been run in the packaging environment; see [TESTING.md](TESTING.md).

## Mac မှာ Web ကို ဖွင့်ရန်

Python 3.9 or newer is required. Extract the ZIP, open Terminal in the `nayyet` folder and run:

```bash
python3 start_web.py
```

Browser မှာ `http://127.0.0.1:8080/` ပွင့်လာပါမယ်။ Terminal ကို ဖွင့်ထားပါ။ ပိတ်ချင်ရင် `Ctrl+C` နှိပ်ပါ။ `index.html` ကို double-click ဖွင့်ရင် calendar data မဖတ်နိုင်ပါ။

If double-clicking `Start-Web.command` is blocked or loses executable permission, use the Terminal command above. If port 8080 is busy:

```bash
python3 start_web.py --port 8081
```

Windows: run `py -3 start_web.py` or `Start-Web.bat`. Linux: `python3 start_web.py`.

## Android / Flutter

Install the stable Flutter SDK, Android Studio and Android SDK. Android 10 (API 29) or newer is required for saving PNGs through scoped media storage. Run `flutter doctor` and resolve its Android toolchain checks. Then, from the extracted project root:

```bash
cd android_flutter
python3 prepare_android.py
flutter test
flutter run
```

The preparation script creates the platform runner with your installed Flutter SDK, preserves `lib/` and assets, sets the application label, copies NayYet launcher icons and installs the Kotlin save/share activity. Running preparation again overwrites that generated MainActivity.kt; keep custom platform changes in platform_templates/MainActivity.kt. Internet is needed for the first SDK/dependency setup. The app itself does not need a network connection.

Build an APK for local testing:

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`.

For a release build, configure your own Android upload keystore and signing configuration first; the generated Flutter runner's default signing setup is not a Play Store release setup. Do not commit keys or `key.properties`.

```bash
flutter build appbundle --release
```

## iOS / SwiftUI

Requires macOS, Xcode 15 or newer and an iOS 17+ simulator/device.

```bash
open ios_swift/NayYet.xcodeproj
```

Choose the **NayYet** scheme and an iPhone simulator, then press **Run**. For a physical device, choose your development team under **Signing & Capabilities** and use a bundle identifier owned by your team. Archive and App Store distribution require your Apple signing setup.

Core tests can also run on macOS without opening Xcode:

```bash
cd ios_swift
swift test
```

## Tests and calendar data

Node.js 20+ is needed only to run web tests:

```bash
cd web
npm test
```

Regenerate data from the repository root with Python:

```bash
python3 tools/build_calendar.py
```

[CALENDAR_NOTES.md](CALENDAR_NOTES.md) explains the algorithm, bounds and table format. [TESTING.md](TESTING.md) records verification and remaining native-device checks.

## GitHub upload

Create a repository named `nayyet`, then upload the **contents** of this folder, including README, LICENSE and the three implementation folders. For the command line, replace the remote below if you use a different repository name:

```bash
git init
git add .
git commit -m "Initial NayYet release"
git branch -M main
git remote add origin https://github.com/itsmeminsithu/nayyet.git
git push -u origin main
```

Suggested GitHub description:

> နေ့ရက် — NayYet: a bilingual Myanmar calendar for Android, iOS and the web, with lunar dates, sabbath days and offline calendar data.

To publish only the web app, enable GitHub Pages with **GitHub Actions** as its source and manually run the **Deploy web calendar** workflow. The website is not published automatically when source is uploaded. For other static hosts, deploy the contents of `web/`.

## License

Application code: MIT © 2026 Min SiThu (itsmeminsithu). Bundled fonts retain their own SIL Open Font License notices. See [LICENSE](LICENSE) and [THIRD_PARTY.md](THIRD_PARTY.md).

## Date search, holidays and quote images

The top search accepts `YYYY-MM-DD` and `DD/MM/YYYY`, including Myanmar digits such as `၀၁/၀၁/၂၀၂၆`. Use the previous/next day buttons to step through past dates. The selected date controls the quote, holiday details and exported image date.

There are 31 original bilingual short reflections. They rotate by civil date, repeat every 31 days, and use the same index on all three platforms. They are not quotations attributed to public figures.

Choose **Universe** or **Skyline**, then export a **1080 × 1350 PNG**:

- Web: Save PNG downloads the image. Share opens the system share sheet where file sharing is supported; otherwise it downloads. Browser download settings decide the save location. If a mobile share sheet rejects the operation, use Save PNG.
- Android: Save PNG writes to **Pictures/NayYet**. Share saves the image there, then opens the system chooser. No broad storage permission is requested on Android 10+.
- iOS: Prepare PNG creates the image, then Share / Save to Files opens the system share sheet. Save to Photos requests add-only photo permission. Denying Photos access does not prevent saving to Files.

The user chooses the destination/social app and confirms posting. NayYet never posts automatically. Native image export code still needs real-device verification.

Sample exported images are in `examples/quote-universe-my.png` and `examples/quote-skyline-en.png`.

## Monthly artwork — v1.2.0

Each month has its own scenery: pagodas, mountains, rivers, skyline, stars and cosmic skies. The same twelve scenes ship with Android, iOS and web. Choose **Monthly theme** when saving a quote to use the selected date’s artwork. See [MONTHLY_THEMES.md](MONTHLY_THEMES.md).

## Quote backgrounds — v1.2.1

The daily quote card now displays the selected date’s monthly scenery on all three platforms, matching the default monthly PNG export. Select a date in a different month to change both. The calendar header follows the month being browsed; the quote follows the selected date shown above it. Universe and Skyline remain optional export overrides. Android waits for the theme image to load before capturing the PNG.
