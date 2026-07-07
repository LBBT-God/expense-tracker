# 💰 My Wallet — Personal Expense Tracker

A clean, modern **personal expense tracker** built with **Flutter** and **Firebase**.
Record your daily income and expenses, browse them by month, visualise spending trends
with charts, set a monthly budget, and have everything stored in the cloud and synced in
realtime with **Cloud Firestore**.

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
| **Delete** | Remove a record with a confirmation dialog from the Detail view. |
| **Charts** | A custom-painted line chart (Week / Month / Year) plus a category breakdown with percentages. |
| **Budget** | Set a monthly budget and track remaining balance with a circular progress indicator. |
| **Persistence** | All data is stored in **Cloud Firestore** and synced across devices in realtime. |

---

## 🧱 Architecture

The app follows a simple, layered structure:

```
UI (Screens / Widgets)
        │  context.watch / context.read
        ▼
State  (TransactionProvider — ChangeNotifier)
        │  toMap / fromMap
        ▼
Model  (Transaction, Category, TransactionType)
        │
        ▼
Storage (Cloud Firestore — realtime NoSQL database)
```

* **State management:** [`provider`](https://pub.dev/packages/provider) with a single
  `ChangeNotifier` (`TransactionProvider`) as the source of truth.
* **Persistence:** transactions live in the `transactions` Firestore collection (one
  document per record); a realtime snapshot listener keeps the UI in sync, and the monthly
  budget is stored in `settings/app`.
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
│   └── discover_screen.dart      # Monthly bill + budget tracking
└── widgets/
    ├── summary_card.dart         # Month income/expense summary header
    └── transaction_tile.dart     # Reusable list row
```

---

## 🛠️ Tech Stack

* **Flutter** (Dart SDK ^3.11) · **Material 3**
* **firebase_core** + **cloud_firestore** — realtime cloud database (CRUD + persistence)
* **provider** — state management
* **intl** — date & number formatting
* **uuid** — unique record IDs
* **fake_cloud_firestore** *(dev)* — in-memory Firestore for tests

---

## 🚀 Getting Started

This app needs a Firebase project (free **Spark** plan is enough).

```bash
# 1. Get dependencies
flutter pub get

# 2. One-time Firebase setup (creates lib/firebase_options.dart)
dart pub global activate flutterfire_cli
flutterfire configure        # sign in, pick/create a Firebase project

# 3. In the Firebase Console: Build → Firestore Database → Create database
#    (start in test mode for development)

# 4. Run on an Android emulator / device or Chrome (web)
flutter run -d chrome        # or: flutter run

# 5. Run the tests (no Firebase needed — uses an in-memory fake)
flutter test
```

> Requires the Flutter SDK installed and on your `PATH`. See the
> [official install guide](https://docs.flutter.dev/get-started/install).
>
> ⚠️ `cloud_firestore` does **not** support the Windows desktop target — run the app on
> an **Android emulator/device** or in **Chrome (web)**.

---

## 🧪 Testing

Automated tests live in the `test/` folder:

* `transaction_model_test.dart` — model serialization (`toMap`/`fromMap`,
  `toJson`/`fromJson`) and `copyWith`.
* `transaction_provider_test.dart` — CRUD operations, income/expense totals, and balance,
  run against an in-memory **fake_cloud_firestore** (no real Firebase connection needed).
* `widget_test.dart` — a smoke test that verifies the main navigation renders.

```bash
flutter test
```

---


## 📄 License

Released under the [MIT License](LICENSE).
