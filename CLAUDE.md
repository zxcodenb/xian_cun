# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🏗️ Project Architecture Overview

This is **果味储物间 (Apple Pantry)** - a Flutter food inventory management app with Apple-style design featuring glassmorphism UI. The entire application is contained in a single Dart file (`lib/main.dart` ~2100 lines).

### Core Architecture Pattern
- **Single-file architecture**: All Flutter code (UI, state management, components) lives in `lib/main.dart`
- **State management**: StatefulWidget + InheritedWidget pattern via `MainShell` → `DashboardScreen` communication
- **Navigation**: Bottom navigation with IndexedStack (Home/Add/Settings)
- **Layout**: CustomScrollView + Slivers for floating header effect

### Data Flow
```
MainShell (global state)
  └─→ _items: List<ProductItem>
       └─→ DashboardScreen (displays via context.findAncestorStateOfType)
            └─→ ProductCard (consumes item)
```

## 🎨 Design System

**Colors** (defined in `AppColors` class):
- Background: `#F5F5F7`
- Brand/Primary: `#0A84FF`
- Text Dark: `#1C1C1E`
- Text Light: `#3C3C4399`
- Status: Safe (`#30D158`), Warning (`#FFD60A`), Urgent (`#FF453A`)

**UI Patterns**:
- Glassmorphism with `BackdropFilter` blur effects
- 24px large corner radius
- Soft shadows for depth
- Breathing animation for urgent items (daysLeft <= 15)

## 📦 Common Development Commands

### Running the App
```bash
# Run in debug mode with hot reload
flutter run

# Build release APK
flutter build apk --release

# Build debug APK
flutter build apk --debug

# Run on specific device
flutter run -d emulator-5554

# Verbose output
flutter run --verbose
```

### Hot Reload
During `flutter run`, press:
- `r` - Hot reload (fastest)
- `R` - Hot restart
- `q` - Quit

### Dependencies
```bash
flutter pub get
```

## 🔑 Key Classes & Components

### State Management
- **`MainShell`**: Root widget, holds global `_items` list
- **`_MainShellState`**: Contains all product data, handles add/remove operations
- **`DashboardScreen`**: Fetches items via `context.findAncestorStateOfType<_MainShellState>()`

### Pages
1. **DashboardScreen** - Product grid with filtering (all/warning/urgent)
2. **AddSelectScreen** - Choose scan or manual add
3. **ManualAddScreen** - Full form with validation
4. **ScannerScreen** - Simulated barcode scanning
5. **SettingsScreen** - Settings placeholder
6. **ProductDetailSheet** - Bottom modal for item details

### Custom Components
- **`ProductCard`** - 2-column grid item with breathing animation
- **`_GlassHeader`** - Floating blur header with dynamic height
- **`_FilterChip`** - Filter buttons with selection states
- **`_StatusDot`** - Status indicator with count (Flexible to prevent overflow)

## ⚠️ Known Issues Fixed (Reference)

These issues were resolved in this codebase:
1. ✅ **NDK corruption** - Fixed by reinstalling NDK via sdkmanager
2. ✅ **Animation ticker warnings** - Fixed by using `TickerProviderStateMixin` instead of `SingleTickerProviderStateMixin`
3. ✅ **Header overflow** - Fixed by implementing `_calculateHeaderHeight()` function
4. ✅ **Syntax error** - Removed extra closing brace
5. ✅ **Field initializer error** - Moved `_pages` from field to build()
6. ✅ **RenderFlex overflow** - Fixed by adding `Flexible` and `maxLines: 2` to greeting text, and `mainAxisSize: MainAxisSize.min` to status dots

### Current Overflow Fix Applied (line 478-500, 543-575)
If you see overflow errors, ensure these widgets have proper constraints:
- Greeting text wrapped in `Flexible` with `maxLines: 2` and `overflow: TextOverflow.ellipsis`
- StatusDot Row uses `mainAxisSize: MainAxisSize.min` with Flexible child

## 📊 Dynamic Features

### Intelligent Greeting Messages (lines 423-461)
The header shows different humorous messages based on inventory state:
- **Empty**: "空空如也，不如囤点菜 🛒" (random from 4 messages)
- **Urgent** (>0 items expiring in ≤3 days): "哎呀，$urgentCount 位小可爱要过期啦..." (random from 4 messages)
- **Warning** (>0 items expiring in 4-15 days): "$warningCount 位朋友即将到点..." (random from 4 messages)
- **Safe** (all items >15 days): "一切都是刚刚好的样子 ✨" (random from 5 messages)

Randomization: `DateTime.now().millisecond % messageList.length`

### Filter System (line 312-316)
```dart
if (filter == 'urgent') return items.where((i) => i.daysLeft <= 3).toList();
if (filter == 'warning') return items.where((i) => i.daysLeft > 3 && i.daysLeft <= 15).toList();
return items;
```

## 🔧 Customization Points

### Adding Sample Data
Edit `_MainShellState()` constructor (lines 87-146) to modify initial products.

### Changing Filter Criteria
Modify `_DashboardScreenState.filteredItems` getter (lines 312-316).

### Adjusting Layout
- **Header height**: Modify `_calculateHeaderHeight()` (lines 280-291)
- **Grid columns**: Change `crossAxisCount` (line 376, currently 2)
- **Card aspect ratio**: Modify `childAspectRatio` (line 377, currently 0.75)

### Status Thresholds
- **Urgent**: ≤3 days (line 663-667, 313)
- **Warning**: 4-15 days (line 664, 314)
- **Breathing animation**: ≤15 days (line 642)

## 📚 Documentation Files

- **`README.md`** - Project overview, setup instructions, features
- **`PROJECT_SUMMARY.md`** - Detailed delivery summary, technical specs, architecture
- **`backend_api_documentation.md`** - 28 REST API endpoints specification
- **`database_schema_design.md`** - PostgreSQL schema with 9 tables, indexes, optimization

## 🎯 Important Implementation Details

### ProductItem Model (lines 29-51)
```dart
final int id, daysLeft, totalDays;
final String name, category, emoji, brand;
final DateTime purchaseDate;
final String? description;
```

### Animation System
- **ProductCard entrance**: `AnimationController` + `Curves.easeOutBack` (400ms)
- **Breathing animation**: For items ≤15 days, 1.5s loop with opacity 0.1→0.3
- **Scan line**: AnimationController with 2s repeat

### Memory-Based State
Current implementation uses in-memory storage only. No persistence layer implemented yet. Backend integration needed for production.

## 🚀 Current Build Status

- ✅ **Compiles successfully** (debug & release)
- ✅ **No runtime errors**
- ✅ **No layout overflow**
- ✅ **Hot reload working**
- ✅ **APK builds** (46.4MB release)

## 📱 Platform Support

- **Android**: Primary target (tested on API 21+, best on Android 8.0+)
- **iOS**: Code uses Cupertino components, should work but not tested
- Minimum SDK: API 21 (Android 5.0)

## 🎨 Design References

- **Apple Human Interface Guidelines** - iOS-style interactions
- **Material Design 3** - Base components
- **Glassmorphism** - BackdropFilter blur effects
- **Color palette** - AppColors class (lines 17-26)

## 💡 Development Tips

1. **Hot reload**: Uses context, so `MainShell` state changes won't hot reload - use hot restart
2. **Testing**: Start emulator before `flutter run` for faster startup
3. **Debugging**: Use Flutter DevTools URL shown in terminal (http://127.0.0.1:XXXXX)
4. **Performance**: Flutter runs with Impeller renderer (OpenGLES)

## 🐛 Troubleshooting

### Build Errors
- Run `flutter clean && flutter pub get` if dependency issues
- Ensure NDK is properly installed: check `/Users/chmod/Library/Android/sdk/ndk/`

### Runtime Errors
- Check console output for RenderFlex overflow (use Flexible/Expanded)
- Verify `context.findAncestorStateOfType` works from child widgets

### Layout Issues
- Header height issues: Adjust `_calculateHeaderHeight()`
- Text overflow: Wrap long text in `Flexible` with `overflow: TextOverflow.ellipsis`

---

**Last Updated**: 2025-11-23
**Flutter Version**: 3.x
**Project Status**: v1.0.0 - Complete frontend implementation
