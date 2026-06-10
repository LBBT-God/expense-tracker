# 💰 My Wallet — Personal Expense Tracker

A clean, modern **personal expense tracker** built with **Flutter**. Record your daily
income and expenses, browse them by month, visualise spending trends with charts, set a
monthly budget, and keep everything stored safely on your own device.

This project was developed for a Mobile Application Development course assignment and
demonstrates a complete **CRUD** application with local state management and a responsive
Material 3 user interface.

---

## ✨ Features

| Area | What it does |
|------|--------------|
| **Create** | Add an income/expense record through a custom numeric keypad, category grid, date picker and note field. |
| **Read** | Browse records grouped by day in the **Ledger**, switch months, and open any record in a detailed view. |
| **Update** | Edit any existing record — the Add screen is reused in "edit" mode. |
| **Delete** | Remove a record with a confirmation dialog, or clear all data from the Profile page. |
| **Charts** | A custom-painted line chart (Week / Month / Year) plus a category breakdown with percentages. |
| **Budget** | Set a monthly budget and track remaining balance with a circular progress indicator. |
| **Persistence** | All data is saved locally with `shared_preferences` — no internet required. |

---

## 🧱 Architecture

The app follows a simple, layered structure:

```
UI (Screens / Widgets)
        │  context.watch / context.read
        ▼
State  (TransactionProvider — ChangeNotifier)
        │  toJson / fromJson
        ▼
Model  (Transaction, Category, TransactionType)
        │
        ▼
Storage (SharedPreferences — local key/value store)
```

* **State management:** [`provider`](https://pub.dev/packages/provider) with a single
  `ChangeNotifier` (`TransactionProvider`) as the source of truth.
* **Persistence:** every mutation (`add` / `update` / `delete`) writes the full list back
  to `SharedPreferences` as a list of JSON strings.
* **UI:** Material 3, an amber (`#FFC107`) brand colour, and a custom bottom navigation bar
  with a central "Record" button.

### Project structure

```
lib/
├── main.dart                     # App entry, theme, Provider injection
├── models/
│   └── transaction.dart          # Transaction model + Category / TransactionType enums
├── providers/
│   └── transaction_provider.dart # CRUD logic, totals, budget, persistence
├── screens/
│   ├── main_screen.dart          # Bottom navigation shell
│   ├── ledger_screen.dart        # Read — list grouped by day
│   ├── add_record_screen.dart    # Create & Update — keypad + categories
│   ├── detail_screen.dart        # Read one + entry points to Update / Delete
│   ├── charts_screen.dart        # Line chart + category breakdown
│   ├── discover_screen.dart      # Monthly bill + budget tracking
│   └── profile_screen.dart       # Stats, settings, clear-all
└── widgets/
    └── transaction_tile.dart     # Reusable list row
```

---

## 🛠️ Tech Stack

* **Flutter** (Dart SDK ^3.11) · **Material 3**
* **provider** — state management
* **shared_preferences** — local persistence
* **intl** — date & number formatting
* **uuid** — unique record IDs

---

## 🚀 Getting Started

```bash
# 1. Get dependencies
flutter pub get

# 2. Run on a connected device / emulator / Chrome
flutter run

# 3. Run the tests
flutter test
```

> Requires the Flutter SDK installed and on your `PATH`. See the
> [official install guide](https://docs.flutter.dev/get-started/install).

---

## 🧪 Testing

Automated tests live in the `test/` folder:

* `transaction_model_test.dart` — model serialization (`toMap`/`fromMap`,
  `toJson`/`fromJson`) and `copyWith`.
* `transaction_provider_test.dart` — CRUD operations, income/expense totals, and balance.
* `widget_test.dart` — a smoke test that builds the app and verifies the Ledger renders.

```bash
flutter test
```

---


## 📄 License

Released under the [MIT License](LICENSE).
