#!/usr/bin/env python3
"""Create the Android runner using the installed Flutter SDK; preserve app source."""
from pathlib import Path
import shutil,subprocess,tempfile
root=Path(__file__).resolve().parent
flutter=shutil.which('flutter')
if not flutter:raise SystemExit('Install Flutter and add flutter/bin to PATH, then run this command again.')
if not (root/'android').exists():
    with tempfile.TemporaryDirectory(prefix='nayyet-android-') as temp:
        generated=Path(temp)/'nayyet'
        subprocess.run([flutter,'create','--platforms=android','--project-name','nayyet','--org','org.minsithu',str(generated)],check=True)
        shutil.copytree(generated/'android',root/'android')
    manifest=root/'android/app/src/main/AndroidManifest.xml'
    manifest.write_text(manifest.read_text().replace('android:label="nayyet"','android:label="နေ့ရက် — NayYet"'),encoding='utf-8')
for icon in (root/'assets/launcher').glob('mipmap-*/ic_launcher.png'):
    destination=root/'android/app/src/main/res'/icon.parent.name/icon.name
    destination.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(icon,destination)
activity=root/'android/app/src/main/kotlin/org/minsithu/nayyet/MainActivity.kt'
activity.parent.mkdir(parents=True,exist_ok=True)
shutil.copy2(root/'platform_templates/MainActivity.kt',activity)
for name in ['build.gradle.kts','build.gradle']:
    gradle=root/'android/app'/name
    if gradle.exists():
        text=gradle.read_text().replace('minSdk = flutter.minSdkVersion','minSdk = 29').replace('minSdkVersion flutter.minSdkVersion','minSdkVersion 29')
        gradle.write_text(text)
subprocess.run([flutter,'pub','get'],cwd=root,check=True)
print('Android runner ready. Run: flutter run  |  flutter build apk --release')
