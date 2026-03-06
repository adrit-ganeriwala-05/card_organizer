# ♠♥♦♣ Card Organizer App

A production-quality Flutter application for organizing standard playing cards into suit-based folders using SQLite local storage with full CRUD operations, foreign key constraints, cascade deletion, and Material 3 design.

> **Course:** Mobile App Development — Flutter & Dart  
> **Assignment:** In-Class Activity 08 — Local Storage with SQLite + Images Part 2  
> **Due:** 03/05/2026 @ 3:00 PM  
> **Team:** Adrit Ganeriwala, [Partner Name]

---

## Table of Contents

- [About the App](#about-the-app)
- [Features](#features)
- [Screenshots](#screenshots)
- [Project Structure](#project-structure)
- [Database Schema](#database-schema)
- [Architecture](#architecture)
- [Dependencies](#dependencies)
- [Setup & Installation](#setup--installation)
- [How to Build the APK](#how-to-build-the-apk)
- [How It Works](#how-it-works)
- [Testing Checklist](#testing-checklist)
- [Known Design Decisions](#known-design-decisions)
- [Team Contributions](#team-contributions)

---

## About the App

The Card Organizer App lets users browse, manage, and organize a standard 52-card playing deck sorted into four suit folders: Hearts, Diamonds, Clubs, and Spades. On first launch, the app automatically creates a SQLite database with four folders and prepopulates all 52 cards with their correct names, suits, and image URLs from the Deck of Cards API.

Users can perform full CRUD operations — creating new cards, viewing card details with images, editing card properties, and deleting cards or entire folders. Deleting a folder triggers SQLite's ON DELETE CASCADE rule, which automatically removes all cards linked to that folder, maintaining referential integrity without any orphaned records.

The app is built with Flutter's Material 3 (Material You) design system, featuring tonal color surfaces, custom-painted suit icons, staggered animations, and edge-to-edge display.

---

## Features

### Core Functionality
- **4 Suit Folders** — Hearts, Diamonds, Clubs, Spades, each prepopulated with 13 cards (52 total)
- **Full CRUD Operations** — Create, Read, Update, and Delete for both folders and cards
- **SQLite Database** — Local persistent storage with two related tables
- **Foreign Key Constraints** — Cards linked to folders via `folder_id` with `ON DELETE CASCADE`
- **Automatic Prepopulation** — All 52 cards inserted on first launch in the `onCreate` callback
- **Card Images** — Network images from deckofcardsapi.com with loading spinners and error fallbacks
- **Search** — Card repository includes a `searchCardsByName()` method for cross-folder search

### User Interface
- **Material 3 Design** — Full Material You theme using `ColorScheme.fromSeed()` with tonal surfaces
- **Custom Suit Icons** — Hearts, Diamonds, Clubs, Spades drawn with `CustomPainter` for crisp rendering at any size
- **Collapsing App Bar** — `SliverAppBar.large` with smooth scroll behavior
- **Staggered Animations** — Cards and folders fade in with staggered timing on load
- **Tonal Folder Colors** — Each suit folder has its own color scheme (warm pink for Hearts, orange for Diamonds, indigo for Clubs, slate for Spades)
- **Card Corner Indicators** — Card tiles display abbreviated names (A, J, Q, K) in corners like real playing cards
- **Watermark Icons** — Large faded suit symbols in folder card backgrounds

### Safety & Error Handling
- **Confirmation Dialogs** — Non-dismissible (`barrierDismissible: false`) dialogs before every delete
- **Cascade Deletion Warning** — Dialog explains how many cards will be removed when a folder is deleted
- **Try-Catch in Every Repository Method** — All database operations wrapped with error logging
- **SnackBar Feedback** — Success and error messages displayed after every action
- **Loading Indicators** — `CircularProgressIndicator` shown during async operations
- **Image Error Fallback** — If a network image fails, suit symbol and card name display instead
- **Form Validation** — Required fields validated before database writes

---

## Screenshots

*Run the app on an emulator or device and add screenshots here:*

| Folders Screen | Cards Screen | Add/Edit Screen | Delete Dialog |
|---|---|---|---|
| *(screenshot)* | *(screenshot)* | *(screenshot)* | *(screenshot)* |

---

## Project Structure

```
card_organizer/
├── pubspec.yaml                              # Dependencies and project config
├── README.md                                 # This file
├── analysis_options.yaml                     # Lint rules
│
├── lib/
│   ├── main.dart                             # App entry point
│   │                                         #   - WidgetsFlutterBinding.ensureInitialized()
│   │                                         #   - Edge-to-edge system UI
│   │                                         #   - MaterialApp with Material 3 theme
│   │
│   ├── theme/
│   │   └── app_theme.dart                    # Material 3 theme configuration
│   │                                         #   - ColorScheme.fromSeed() with green seed
│   │                                         #   - Rounded 16dp corners on all components
│   │                                         #   - Custom AppBar, Card, FAB, Dialog themes
│   │                                         #   - Filled input decorations
│   │
│   ├── widgets/
│   │   └── suit_icon.dart                    # Custom-painted suit symbols
│   │                                         #   - SuitIcon widget using CustomPainter
│   │                                         #   - Heart: parametric heart curve equation
│   │                                         #   - Diamond: curved rhombus with cubic beziers
│   │                                         #   - Spade: inverted heart + tapered stem
│   │                                         #   - Club: three circles + tapered stem
│   │                                         #   - Helper functions: suitFromString(),
│   │                                         #     suitSymbol(), suitColor(), isSuitRed()
│   │
│   ├── database/
│   │   └── database_helper.dart              # SQLite database setup (Singleton pattern)
│   │                                         #   - Creates card_organizer.db
│   │                                         #   - PRAGMA foreign_keys = ON in onConfigure
│   │                                         #   - Two tables: folders, cards
│   │                                         #   - ON DELETE CASCADE on cards.folder_id
│   │                                         #   - Prepopulates 4 folders × 13 cards = 52
│   │                                         #   - Image URLs from deckofcardsapi.com
│   │                                         #   - Debug helper: printDatabaseContents()
│   │
│   ├── models/
│   │   ├── folder.dart                       # Folder data model
│   │   │                                     #   - Fields: id, folderName, timestamp
│   │   │                                     #   - toMap(), fromMap(), copyWith(), toString()
│   │   │
│   │   └── card.dart                         # PlayingCard data model
│   │                                         #   - Named PlayingCard to avoid Flutter Card clash
│   │                                         #   - Fields: id, cardName, suit, imageUrl, folderId
│   │                                         #   - toMap(), fromMap(), copyWith(), toString()
│   │
│   ├── repositories/
│   │   ├── folder_repository.dart            # Folder CRUD operations
│   │   │                                     #   - insertFolder()
│   │   │                                     #   - getAllFolders()
│   │   │                                     #   - getFolderById()
│   │   │                                     #   - updateFolder()
│   │   │                                     #   - deleteFolder() — triggers CASCADE
│   │   │                                     #   - getCardCount()
│   │   │
│   │   └── card_repository.dart              # Card CRUD operations
│   │                                         #   - insertCard()
│   │                                         #   - getCardsByFolderId()
│   │                                         #   - getCardById()
│   │                                         #   - getAllCards()
│   │                                         #   - updateCard()
│   │                                         #   - deleteCard()
│   │                                         #   - searchCardsByName()
│   │
│   └── screens/
│       ├── folders_screen.dart               # Main screen — suit folder grid
│       │                                     #   - SliverAppBar.large with collapsing header
│       │                                     #   - Stat chips showing folder/card totals
│       │                                     #   - 2-column grid of FolderCards
│       │                                     #   - Staggered fade+slide animations
│       │                                     #   - Tonal background per suit
│       │                                     #   - Watermark suit icon in card background
│       │                                     #   - Delete with cascade warning dialog
│       │                                     #   - Pull-to-refresh on return from CardScreen
│       │
│       ├── cards_screen.dart                 # Cards inside a selected folder
│       │                                     #   - SliverAppBar.medium with suit icon in title
│       │                                     #   - 3-column grid of PlayingCardTiles
│       │                                     #   - Corner indicators (A, J, Q, K) like real cards
│       │                                     #   - Network image with loading/error states
│       │                                     #   - PopupMenuButton for edit/delete per card
│       │                                     #   - FAB.extended to add new cards
│       │                                     #   - Staggered fade animations
│       │
│       └── add_edit_card_screen.dart         # Form to create or edit a card
│                                             #   - Dual mode: Add (card=null) / Edit (card!=null)
│                                             #   - TextFormField for card name and image URL
│                                             #   - DropdownButtonFormField for suit and folder
│                                             #   - Animated image preview panel
│                                             #   - Form validation on all fields
│                                             #   - Save button in AppBar (FilledButton)
│                                             #   - Tip card with image URL format guide
│                                             #   - Loading state during save
│
└── assets/
    └── suits/                                # SVG suit icons (reference only)
        ├── hearts.svg
        ├── diamonds.svg
        ├── spades.svg
        └── clubs.svg
```

---

## Database Schema

### Folders Table

| Column      | Type    | Constraints              | Description                          |
|-------------|---------|--------------------------|--------------------------------------|
| id          | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique folder identifier             |
| folder_name | TEXT    | NOT NULL                 | Suit name (Hearts, Spades, etc.)     |
| timestamp   | TEXT    | NOT NULL                 | ISO 8601 creation date/time          |

### Cards Table

| Column    | Type    | Constraints                                      | Description                       |
|-----------|---------|--------------------------------------------------|-----------------------------------|
| id        | INTEGER | PRIMARY KEY AUTOINCREMENT                        | Unique card identifier            |
| card_name | TEXT    | NOT NULL                                         | Card name (Ace, King, 2, etc.)    |
| suit      | TEXT    | NOT NULL                                         | Card suit (Hearts, Spades, etc.)  |
| image_url | TEXT    | NOT NULL                                         | Network image URL                 |
| folder_id | INTEGER | NOT NULL, FOREIGN KEY → folders(id) ON DELETE CASCADE | Links card to its parent folder |

### Entity Relationship

```
┌─────────────┐         ┌─────────────────┐
│   folders    │         │      cards      │
├─────────────┤         ├─────────────────┤
│ id (PK)     │───┐     │ id (PK)         │
│ folder_name │   │     │ card_name       │
│ timestamp   │   │     │ suit            │
└─────────────┘   │     │ image_url       │
                  └────▶│ folder_id (FK)  │
                         └─────────────────┘
                  One-to-Many (1 folder : N cards)
                  ON DELETE CASCADE
```

### Key Database Decisions

- **PRAGMA foreign_keys = ON** is set in `onConfigure` because SQLite disables foreign key enforcement by default
- **ON DELETE CASCADE** ensures deleting a folder automatically removes all its cards
- **Prepopulation** runs inside `onCreate` — 4 folders and 52 cards are inserted in a single transaction on first launch
- **Image URLs** follow the pattern `https://deckofcardsapi.com/static/img/{VALUE}{SUIT}.png` (e.g., `AH.png` = Ace of Hearts)

---

## Architecture

The app follows the **Repository Pattern** with three distinct layers:

```
┌──────────────────────────────────────────┐
│              UI Layer (screens/)          │
│  FoldersScreen, CardsScreen, AddEditCard │
│  - Handles user interaction              │
│  - Manages widget state with setState    │
│  - Shows loading/error/success states    │
├──────────────────────────────────────────┤
│          Repository Layer                │
│  FolderRepository, CardRepository        │
│  - Provides clean CRUD API               │
│  - Wraps all calls in try-catch          │
│  - Converts Maps ↔ Model objects         │
├──────────────────────────────────────────┤
│            Data Layer                    │
│  DatabaseHelper (Singleton)              │
│  - Manages SQLite connection             │
│  - Schema creation and migrations        │
│  - Foreign key configuration             │
│  Folder model, PlayingCard model         │
│  - toMap(), fromMap(), copyWith()        │
└──────────────────────────────────────────┘
```

### Why This Architecture?

- **Separation of Concerns** — UI code never contains SQL queries; repositories never render widgets
- **Testability** — Repositories can be unit tested independently without the Flutter widget tree
- **Maintainability** — Changing the database (e.g., switching from sqflite to drift) only requires updating the data layer
- **Reusability** — The same repository methods are called from multiple screens

---

## Dependencies

| Package         | Version | Purpose                                  |
|-----------------|---------|------------------------------------------|
| `sqflite`       | ^2.3.0  | SQLite database plugin for Flutter       |
| `path`          | ^1.8.3  | File path manipulation utilities         |
| `path_provider` | ^2.1.1  | Access to platform-specific directories  |
| `intl`          | ^0.18.1 | Date/time formatting for timestamps      |

---

## Setup & Installation

### Prerequisites

- Flutter SDK 3.0+ installed and on PATH
- Android Studio or VS Code with Flutter extension
- Android emulator or physical device connected

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/adrit-ganeriwala-05/card_organizer.git
cd card_organizer

# 2. Install dependencies
flutter pub get

# 3. Verify setup
flutter doctor
flutter analyze

# 4. Run on connected device/emulator
flutter run
```

### First Launch Behavior

On first launch, the app automatically:
1. Creates `card_organizer.db` in the app's database directory
2. Enables foreign key enforcement (`PRAGMA foreign_keys = ON`)
3. Creates the `folders` and `cards` tables
4. Inserts 4 suit folders (Hearts, Spades, Diamonds, Clubs)
5. Inserts 13 cards per folder (52 total) with correct image URLs

No manual data entry is needed.

---

## How to Build the APK

```bash
# Debug APK (faster build, larger size)
flutter build apk --debug

# Release APK (optimized, smaller size)
flutter build apk --release
```

The APK file will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## How It Works

### User Flow: Viewing Cards
1. User opens app → `FoldersScreen` loads
2. `FolderRepository.getAllFolders()` queries the database
3. For each folder, `getCardCount()` runs a COUNT query
4. Folders display in a 2-column grid with suit icons and card counts
5. User taps a folder → `CardsScreen` opens with the selected folder
6. `CardRepository.getCardsByFolderId()` fetches all cards for that folder
7. Cards display in a 3-column grid with network images

### User Flow: Adding a Card
1. User taps the FAB (+ Add Card) on `CardsScreen`
2. `AddEditCardScreen` opens in Add mode (`card == null`)
3. User fills in card name, selects suit, enters image URL, picks folder
4. Form validation checks all fields are non-empty
5. User taps Save → `CardRepository.insertCard()` writes to SQLite
6. Navigator pops back, `CardsScreen` reloads from database

### User Flow: Deleting a Folder (Cascade)
1. User taps the delete icon on a folder card
2. Non-dismissible `AlertDialog` appears showing folder name and card count
3. Dialog explains cascade deletion ("all X cards will be removed")
4. User confirms → `FolderRepository.deleteFolder()` runs
5. SQLite's `ON DELETE CASCADE` automatically deletes all linked cards
6. SnackBar confirms deletion, folder grid refreshes

---

## Testing Checklist

- [x] Database creates and prepopulates on first launch (4 folders, 52 cards)
- [x] All 4 suit folders display with accurate card counts
- [x] Tapping a folder shows its 13 cards
- [x] Can add a new card with all required fields
- [x] All cards display with images, names, and suits
- [x] Can edit an existing card and changes persist
- [x] Can delete individual cards without affecting others
- [x] Deleting a folder cascades to delete all its cards
- [x] Delete actions show confirmation dialogs with warnings
- [x] Cards remain linked to correct folders after updates
- [x] Closing and reopening app maintains all data
- [x] Image loading shows spinner; failed images show fallback
- [x] App handles invalid input without crashing
- [x] No lag or freezing during database operations
- [x] Smooth navigation between all screens

---

## Known Design Decisions

| Decision | Reasoning |
|---|---|
| **Network images over assets** | Keeps APK size small; deckofcardsapi.com is reliable; Flutter caches after first load |
| **PlayingCard class name** | Avoids conflict with Flutter's built-in `Card` widget |
| **setState over Provider** | Appropriate complexity for a 3-screen app; avoids unnecessary dependencies |
| **CustomPainter for suit icons** | Renders crisply at any size without raster artifacts; no external icon package needed |
| **Singleton DatabaseHelper** | Ensures a single database connection across the entire app lifecycle |
| **PRAGMA foreign_keys in onConfigure** | Must be set on every connection because SQLite defaults to OFF |
| **Prepopulate all 52 cards** | Standard deck data is static and well-known; manual entry adds no value |
| **Non-dismissible delete dialogs** | Prevents accidental data loss from tapping outside the dialog |

---

## Team Contributions

| Member | Contributions |
|---|---|
| Adrit Ganeriwala | *Describe your contributions here* |
| [Partner Name] | *Describe partner contributions here* |

---

*Built with Flutter, Dart, and SQLite for GSU Mobile App Development — Spring 2026*
