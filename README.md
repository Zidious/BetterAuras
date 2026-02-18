# BetterAuras

<img src="Assets/BetterAuras_Logo.png" alt="BetterAuras Logo" align="left" width="120" style="margin-right: 20px;">

Customize the appearance of buffs and debuffs on party and raid frames. Adjust size, positioning, spacing, padding, and stack count display with real-time preview.

<br clear="left"/>

<div align="center">
<img src="Assets/BetterAuras_Config.png" alt="BetterAuras Configuration Panel" width="500">
</div>

## Features

- Independent buff and debuff sizing (10-40px)
- Flexible anchoring with 4 anchor points
- Customizable spacing and padding
- Stack count font size and position control
- Live preview panel
- Profile system with per-character support
- Instant application of changes

## Installation

1. Extract the `BetterAuras` folder to `World of Warcraft\_retail_\Interface\AddOns\`
2. Type `/reload`
3. Type `/ba` to open settings

## Usage

Open the configuration panel with `/ba` and use the sliders to customize your auras. Changes apply instantly to all party and raid frames. Create profiles for different situations (PvE, PvP, etc.) using the profile dropdown.

## Configuration

### Available Settings

**For Both Buffs and Debuffs:**

- Size (10-40px) - Default: Buffs 20px, Debuffs 26px
- Spacing (0-10px) - Default: 2px
- Padding (0-20px for each edge) - Default: 4px top/right/left, 10px bottom
- Stack font size (6-20pt) - Default: 12pt
- Stack position offsets (-10 to +10px)
- Anchor point (Top Left, Top Right, Bottom Left, Bottom Right)

All changes update in real-time on party/raid frames.

## Profiles

Create, copy, switch, and delete profiles from the dropdown menu. Each character remembers its last used profile. Profiles are saved in `BetterAurasDB` and are account-wide.

## Commands

- `/ba` or `/betterauras` - Toggle settings panel
- `/ba show` - Show settings panel
- `/ba hide` - Hide settings panel
- `/ba help` - Show help

## FAQ

**Q: Does this work with ElvUI, Grid2, or other raid frame addons?**  
A: No, BetterAuras is designed for default Blizzard party and raid frames only.

**Q: Do I need to reload my UI?**  
A: No, all changes apply instantly.

**Q: How do I reset to defaults?**  
A: Create a new profile, which starts with default values.

## File Structure

```
BetterAuras/
├── Core/           # Initialization, database, constants
├── Modules/        # Aura updates, anchoring, frame hooks
└── UI/             # Config panel, preview, profiles, controls
```
