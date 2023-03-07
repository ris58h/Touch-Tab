# Touch-Tab

![Touch-Tab AppSwitcher](https://user-images.githubusercontent.com/511242/185958284-e0f962aa-3f88-4d95-9176-3f3fe49a24c8.gif)

Switch apps with trackpad on macOS.
Use 3-fingers swipe right or 3-fingers swipe left to switch between apps.
Hold after the swipe or swipe slowly to show App Switcher UI.

## Installation
1. Download the [latest](https://github.com/ris58h/Touch-Tab/releases/download/v1.1.0/Touch-Tab-1.1.0.zip) `Touch-Tab-VERSION.zip` from [Releases](https://github.com/ris58h/Touch-Tab/releases) page.
2. Unzip the archive and move `Touch-Tab.app` into the `Applications` folder.
3. The app is ad-hoc signed so when you run the app macOS will warn you: `"Touch-Tab" can’t be opened because Apple cannot check it for malicious software`. Right-click the app and click `Open`, a 
pop-up will appear, click `Open` again.
4. The app needs access to global trackpad events. Allow Touch-Tab to control your computer in `System Settings > Privacy & Security > Accesibility`. If you had Touch-Tab installed before you may need to remove Touch-Tab from the `Accessibility` list.
5. Disable 3-finger swipe between full-screen apps or make it 4-finger in `System Settings > Trackpad > More Gestures > Swipe between full-screen apps`.

## Usage
- Use 3-fingers swipe right or 3-fingers swipe left to switch between apps.
- Hold after the swipe or swipe slowly to show App Switcher UI. Pro tip: you can use 2-fingers scroll to switch apps in App Switcher faster.

## Troubleshooting
### "Touch-Tab" can’t be opened because Apple cannot check it for malicious software
Right-click the app and click `Open`, a pop-up will appear, click `Open` again.
### It's running but doesn't work
- Check that Touch-Tab is allowed to control your computer in `System Settings > Privacy & Security > Accesibility`.  If you had Touch-Tab installed before you may need to remove Touch-Tab from the `Accessibility` list.
- Check that 3-finger swipe is disabled in `System Settings > Trackpad > More Gestures > Swipe between full-screen apps`.
### 3-finger swipe scrolls a content
It's a [known issue](https://github.com/ris58h/Touch-Tab/issues/1). The workaround is to setup `Mission Control` or `App Expose` to use 3-finger swipe.
### It still doesn't work
Please create an [issue](https://github.com/ris58h/Touch-Tab/issues).
