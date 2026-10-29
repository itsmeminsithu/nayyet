# နေ့ရက် — NayYet

မြန်မာရက်စွဲ၊ လဆန်းလဆုတ်နဲ့ ဥပုသ်နေ့တွေကို နေ့စဉ်ကြည့်ဖို့။

I kept having to work out the Myanmar date from the Gregorian one, so I built this. NayYet shows both side by side — Myanmar date, lunar phase, sabbath days — on Android, iOS and web, in Myanmar and English.

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

It needs no account, API key, database, analytics or backend. The native apps carry their calendar data and fonts with them. The web app caches files after a first visit that succeeds over HTTPS or localhost; if the browser clears its cache, offline access goes with it. Selected 2026 public holidays and recurring international observances are included. See HOLIDAYS.md for coverage and for where sources disagreed.

## Folders

| Folder | Implementation |
| --- | --- |
| `web/` | HTML, CSS and JavaScript; no build step |
| `android_flutter/` | Flutter app, Android runner setup script, tests |
| `ios_swift/` | SwiftUI app, Xcode project, Swift Package core tests |
| `shared/` | Canonical calendar data, test vectors and licensed fonts |
| `tools/` | Reproducible Python calendar-data generator |

Before you download: this is a **source package**. There is no APK, IPA, signing certificate or store release in it. The web side was tested in browsers. Flutter and Xcode builds were not run in the packaging environment; see [TESTING.md](TESTING.md).

## Mac မှာ Web ကို ဖွင့်ရန်

You need Python 3.9 or newer. Extract the ZIP, open Terminal in the `nayyet` folder and run:

```bash
python3 start_web.py
```

Browser မှာ `http://127.0.0.1:8080/` ပွင့်လာပါမယ်။ Terminal ကို ဖွင့်ထားပါ။ ပိတ်ချင်ရင် `Ctrl+C` နှိပ်ပါ။ `index.html` ကို double-click ဖွင့်ရင် calendar data မဖတ်နိုင်ပါ။

If double-clicking `Start-Web.command` is blocked or the file lost its executable permission, use the Terminal command above. If port 8080 is busy:

```bash
python3 start_web.py --port 8081
```

Windows: run `py -3 start_web.py` or `Start-Web.bat`. Linux: `python3 start_web.py`.

## Android / Flutter

Install the stable Flutter SDK, Android Studio and the Android SDK. Saving PNGs through scoped media storage needs Android 10 (API 29) or newer. Run `flutter doctor` and fix what it flags in the Android toolchain. Then, from the project root:

```bash
cd android_flutter
python3 prepare_android.py
flutter test
flutter run
```

The preparation script builds the platform runner with your Flutter SDK, keeps `lib/` and assets, sets the app label, copies the NayYet launcher icons and installs the Kotlin save/share activity. Run it again and it overwrites the generated MainActivity.kt, so keep your own platform changes in platform_templates/MainActivity.kt. The first SDK and dependency setup needs internet. The app itself does not.

APK for local testing:

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`.

For a release build, set up your own Android upload keystore and signing first. The generated runner's default signing is not a Play Store setup. Do not commit keys or `key.properties`.

```bash
flutter build appbundle --release
```

## iOS / SwiftUI

You need a Mac, Xcode 15 or newer and an iOS 17+ simulator or device.

```bash
open ios_swift/NayYet.xcodeproj
```

Pick the **NayYet** scheme and an iPhone simulator, then press **Run**. On a real device, set your development team under **Signing & Capabilities** and use a bundle identifier your team owns. Archiving and App Store release need your own Apple signing setup.

Core tests without opening Xcode:

```bash
cd ios_swift
swift test
```

## Tests and calendar data

Node.js 20+ is only needed for the web tests:

```bash
cd web
npm test
```

Regenerate the data from the repository root:

```bash
python3 tools/build_calendar.py
```

[CALENDAR_NOTES.md](CALENDAR_NOTES.md) covers the algorithm, the date bounds and the table format. [TESTING.md](TESTING.md) records what was checked and which device checks are still open.

## Putting it on GitHub

Create a repository named `nayyet` and upload the **contents** of this folder, including README, LICENSE and the three implementation folders. From the command line (change the remote if you use a different repo name):

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

To publish the web app, enable GitHub Pages with **GitHub Actions** as the source and run the **Deploy web calendar** workflow yourself. Uploading the source does not publish the site on its own. On other static hosts, deploy the contents of `web/`.

## License

Application code: MIT © 2026 Min SiThu (itsmeminsithu). Bundled fonts keep their own SIL Open Font License notices. See [LICENSE](LICENSE) and [THIRD_PARTY.md](THIRD_PARTY.md).

## Date search, holidays and quote images

The search box at the top takes `YYYY-MM-DD` and `DD/MM/YYYY`, including Myanmar digits such as `၀၁/၀၁/၂၀၂၆`. The previous/next day buttons step through past dates. The date you select drives the quote, the holiday details and the date on the exported image.

There are 31 short bilingual reflections written for this app. They rotate by civil date, repeat every 31 days, and use the same index on all three platforms. They are not quotes from public figures.

Pick **Universe** or **Skyline**, then export a **1080 × 1350 PNG**.

- Web: Save PNG downloads the image. Share opens the system share sheet where file sharing is supported, and downloads instead where it is not. Your browser's download settings decide where it lands. If a mobile share sheet refuses, use Save PNG.
- Android: Save PNG writes to **Pictures/NayYet**. Share saves the image there first, then opens the system chooser. No broad storage permission is asked for on Android 10+.
- iOS: Prepare PNG builds the image, then Share / Save to Files opens the system share sheet. Save to Photos asks for add-only photo permission. Saying no to Photos does not block saving to Files.

You pick the app and confirm the post. NayYet never posts on its own. Native image export still needs checking on a real device.

Sample exports: `examples/quote-universe-my.png` and `examples/quote-skyline-en.png`.

## Monthly artwork — v1.2.0

Each month has its own scenery: pagodas, mountains, rivers, skyline, stars and cosmic skies. The same twelve scenes ship on Android, iOS and web. Choose **Monthly theme** when saving a quote to use that date's artwork. See [MONTHLY_THEMES.md](MONTHLY_THEMES.md).

## Quote backgrounds — v1.2.1

The daily quote card now shows the selected date's monthly scenery on all three platforms, which matches the default monthly PNG export. Pick a date in another month and both change. The calendar header follows the month you are browsing; the quote follows the selected date above it. Universe and Skyline are still there as export overrides. On Android, the app waits for the theme image to load before it captures the PNG.
