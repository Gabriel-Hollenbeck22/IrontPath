# IronPath App Icon Specifications

## Required Files

Place the following PNG files in `Assets.xcassets/AppIcon.appiconset/`:

### 1. AppIcon.png (Light Mode)
- **Size**: 1024x1024 pixels
- **Format**: PNG, no alpha channel
- **Design**: 
  - Background: Gradient from #33A1FF (top-left) to #1A7AD4 (bottom-right)
  - Icon: White stylized "IP" monogram or dumbbell icon
  - Corner radius: Applied automatically by iOS

### 2. AppIcon-Dark.png (Dark Mode)
- **Size**: 1024x1024 pixels
- **Format**: PNG, no alpha channel
- **Design**: 
  - Background: Dark gradient from #1A1A2E to #16213E
  - Icon: Bright cyan (#33A1FF) stylized "IP" or dumbbell
  - Subtle glow effect around icon

### 3. AppIcon-Tinted.png (Tinted Mode - iOS 18+)
- **Size**: 1024x1024 pixels  
- **Format**: PNG, no alpha channel
- **Design**:
  - Background: Solid dark (#1A1A1A)
  - Icon: White/light gray monochrome version
  - High contrast for tint overlay

## Design Guidelines

### Color Palette
- Primary Blue: #33A1FF (RGB: 51, 161, 255)
- Dark Blue: #1A7AD4 (RGB: 26, 122, 212)
- Dark Background: #1A1A2E
- Pure White: #FFFFFF

### Icon Concepts

**Option A - Monogram Style**
```
   ╭─────────╮
   │   IP    │
   │  ──────  │
   │   PATH  │
   ╰─────────╯
```
Stylized "IP" letters with a subtle path/progress line underneath

**Option B - Fitness Icon**
```
      ●══●
      │  │
   ●══●══●══●
      │  │
      ●══●
```
Minimalist dumbbell with integrated path element

**Option C - Abstract Strength**
```
     ╱╲
    ╱  ╲
   ╱ ▲▲ ╲
  ╱──────╲
```
Mountain/progression peaks representing growth

### Technical Notes
- Export at exactly 1024x1024
- No transparency (use solid background)
- No rounded corners (iOS applies them)
- Center icon with ~20% margin from edges
- Test at small sizes (29pt, 40pt, 60pt)

## Quick Creation with SF Symbols

If you have access to design tools, you can use:
- SF Symbol: `figure.strengthtraining.traditional`
- SF Symbol: `dumbbell.fill`
- SF Symbol: `chart.line.uptrend.xyaxis`

Export at high resolution with your brand colors.

## Recommended Tools
- Figma (free)
- Sketch
- Adobe Illustrator
- Canva (with export at 1024x1024)
- SF Symbols app (for reference)
