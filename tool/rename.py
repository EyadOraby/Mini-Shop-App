"""One-off rename: Mini Shop -> The Maker's Market (package, app IDs, titles, CI paths)."""
import glob
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)


def edit(path, *pairs, regex=False):
    s = open(path, encoding='utf8').read()
    for a, b in pairs:
        s = re.sub(a, b, s) if regex else s.replace(a, b)
    open(path, 'w', encoding='utf8', newline='').write(s)


for f in glob.glob('lib/**/*.dart', recursive=True) + glob.glob('test/**/*.dart', recursive=True):
    edit(f, ('package:mini_shop/', 'package:makers_market/'), ('MiniShopApp', 'MakersMarketApp'))

edit('pubspec.yaml', ('name: mini_shop', 'name: makers_market'),
     ('description: "Mini Shop: a Flutter shopping app with BLoC, Dio and an offline Hive cart."',
      'description: "The Maker\'s Market: Egyptian handmade crafts, built with Flutter, BLoC, Dio and Hive."'))
edit('lib/main.dart', ("HiveStore.open('mini_shop')", "HiveStore.open('makers_market')"), ("title: 'Mini Shop'", "title: \"The Maker's Market\""))
edit('.github/workflows/flutter.yml', ('/Mini-Shop-App/app/', '/makers-market/app/'), ('mini-shop.apk', 'makers-market.apk'))
edit('android/app/src/main/AndroidManifest.xml', ('android:label="Mini Shop"', 'android:label="Maker\'s Market"'))
edit('ios/Runner/Info.plist', ('<string>Mini Shop</string>', "<string>Maker's Market</string>"))
edit('web/index.html', ('content="Mini Shop"', 'content="Maker\'s Market"'), ('<title>Mini Shop</title>', "<title>The Maker's Market</title>"))
edit('web/manifest.json', ('"name": "Mini Shop"', '"name": "The Maker\'s Market"'), ('"short_name": "Mini Shop"', '"short_name": "Maker\'s Market"'))

# Android application ID and Kotlin package.
edit('android/app/build.gradle.kts', ('com.example.corporatica_task_2', 'com.eyadoraby.makersmarket'))
old = 'android/app/src/main/kotlin/com/example/corporatica_task_2/MainActivity.kt'
new = 'android/app/src/main/kotlin/com/eyadoraby/makersmarket/MainActivity.kt'
os.makedirs(os.path.dirname(new), exist_ok=True)
s = open(old, encoding='utf8').read().replace('com.example.corporatica_task_2', 'com.eyadoraby.makersmarket')
open(new, 'w', encoding='utf8').write(s)
os.remove(old)
for d in ['android/app/src/main/kotlin/com/example/corporatica_task_2', 'android/app/src/main/kotlin/com/example']:
    if os.path.isdir(d) and not os.listdir(d):
        os.rmdir(d)

# iOS / macOS bundle identifiers.
for f in ['ios/Runner.xcodeproj/project.pbxproj', 'macos/Runner.xcodeproj/project.pbxproj']:
    edit(f, (r'com\.example\.corporaticaTask2', 'com.eyadoraby.makersmarket'), (r'com\.example\.corporatica_task_2', 'com.eyadoraby.makersmarket'), regex=True)
print('renamed')
