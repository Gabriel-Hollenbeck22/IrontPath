# IronPath Widget Setup Guide

This document explains how to add the widget extension to your Xcode project.

## Step 1: Add Widget Extension Target

1. In Xcode, go to **File > New > Target**
2. Select **Widget Extension**
3. Name it **IronPathWidget**
4. Uncheck "Include Configuration App Intent" (we use static configuration)
5. Click **Finish**

## Step 2: Configure App Groups

Both the main app and widget need to share data via App Groups.

### Main App Target:
1. Select the **IronPath** target
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Add **App Groups**
5. Click the **+** and add: `group.com.ironpath.shared`

### Widget Target:
1. Select the **IronPathWidget** target
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Add **App Groups**
5. Select the same group: `group.com.ironpath.shared`

## Step 3: Replace Generated Files

Replace the auto-generated widget files with the ones in this folder:
- `IronPathWidgetBundle.swift`
- `StreakWidget.swift`
- `TodayProgressWidget.swift`

## Step 4: Add Assets

Copy the `Assets.xcassets` folder contents to the widget target's assets.

## Step 5: Update Info.plist (if needed)

The widget should automatically use the bundle display name. If you want a custom name:

```xml
<key>CFBundleDisplayName</key>
<string>IronPath</string>
```

## Step 6: Verify Widget Data Sync

The `WidgetDataService` in the main app syncs data to App Groups. Call these methods when data changes:

```swift
// When nutrition is logged
WidgetDataService.shared.syncTodayNutrition(from: dailySummary)

// When streaks update
WidgetDataService.shared.syncStreakData(from: streakData)

// When profile targets change
WidgetDataService.shared.syncUserTargets(from: userProfile)
```

## Widget Sizes

### Streak Widget
- **Small**: Shows workout streak with flame icon
- **Medium**: Shows workout, nutrition, and combined streaks

### Today's Progress Widget
- **Small**: Circular calorie progress ring
- **Medium**: Calorie ring + macro progress bars
- **Large**: Full nutrition breakdown with detailed progress

## Testing

1. Build and run the main app first
2. Add the widget to your home screen (long press > + button)
3. Search for "IronPath"
4. Select desired widget size

## Troubleshooting

### Widget shows placeholder data
- Make sure App Groups are configured correctly
- Verify `WidgetDataService` is called when data changes

### Widget doesn't update
- Call `WidgetCenter.shared.reloadTimelines(ofKind:)` after data changes
- Check that the main app has written to UserDefaults

### Build errors
- Ensure both targets have the same Team/Signing settings
- Widget minimum deployment should match main app
