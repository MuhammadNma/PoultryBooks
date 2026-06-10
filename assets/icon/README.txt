ICON SETUP INSTRUCTIONS
=======================

You need to add two image files to this folder before running the icon generator:

1. app_icon.png        — 1024x1024 PNG, your main app icon
2. app_icon_foreground.png — 1024x1024 PNG, foreground layer for Android adaptive icon
   (should have transparent background, icon centered in the middle 66% of the canvas)

After adding your icons, run these commands:

  flutter pub get
  dart run flutter_launcher_icons
  dart run flutter_native_splash:create

QUICK OPTION (use Flutter default green icon for now):
If you don't have a custom icon yet, you can skip this and 
use the default Flutter icon until you're ready to design one.
Just remove "flutter_launcher_icons" from pubspec.yaml dependencies
and remove the assets section.

DESIGN TIPS:
- Use a chicken, egg, or farm-related icon
- Green (#2E7D32) background works well with white icon
- Keep the icon simple — it will be shown at 48x48 pixels on most phones
