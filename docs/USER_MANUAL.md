# 📘 My Wallet — Setup & Demo Guide (for the team)

This guide shows **every group member** how to get the app running on their own laptop,
demonstrate all the features, and show that the data is stored in **Cloud Firestore**.

> **Project:** My Wallet — Personal Expense Tracker · DES3113
> **Repo:** https://github.com/LBBT-God/expense-tracker
> **Firebase project:** `des3113-7d1fe` (shared by the whole team)

---

## 1. What the app is

A personal expense tracker built with **Flutter**. You record income/expense entries; the
app stores them in **Cloud Firestore** (Google's cloud database) and shows them in a ledger,
charts, and a budget tracker. It does full **CRUD** — Create, Read, Update, Delete.

---

## 2. What you need to install (one time)

| Tool | Why | Link |
|------|-----|------|
| **Flutter SDK** | builds & runs the app | https://docs.flutter.dev/get-started/install |
| **Google Chrome** | we run the app in the browser | (already on most PCs) |
| **Git** | to download the code | https://git-scm.com/downloads |

After installing Flutter, check it works:
```bash
flutter doctor
```

---

## 3. Get the project (one time)

Open a terminal **(PowerShell on Windows)** and run:
```bash
git clone https://github.com/LBBT-God/expense-tracker.git
cd expense-tracker
flutter pub get
```

> ✅ **You do NOT need to set up Firebase yourself.** The Firebase configuration
> (`lib/firebase_options.dart`) is already in the project and points to our shared
> team project. Everyone's app reads and writes the **same** cloud database.

---

## 4. Run the app

```bash
flutter run -d chrome
```

The first run takes ~1 minute to compile, then Chrome opens with the app.

> ⚠️ **Run it in Chrome (web).** Our Firebase config is set up for the web target.
> Don't use the Windows desktop or an Android emulator unless you add that platform first.

---

## 5. Demo script — what to click (≈3 minutes)

Follow this order during the presentation; it covers the whole rubric.

| Step | Action | What it proves |
|------|--------|----------------|
| **1. Create** | Tap the yellow **➕** at the bottom → type an amount on the keypad → pick a category → (optional note/date) → **Save** | **Create** |
| **2. Read (list)** | The entry appears on the **Ledger**, grouped by day, with the month's income/expense totals | **Read — list view** |
| **3. Read (detail)** | Tap the entry → opens the **Detail** screen with full info | **Read — detail view** |
| **4. Update** | On Detail, tap the **edit ✏️** icon → change the amount → **Save** | **Update** |
| **5. Delete** | On Detail, tap **delete 🗑️** → confirm | **Delete** |
| **6. Budget** | **Discover** tab → **Set Budget** → enter a number → watch the progress ring | extra feature |
| **7. Charts** | **Charts** tab → switch Week / Month / Year + see the category breakdown | UI/UX |

Tip: add 4–5 sample entries (mix of income & expense) **before** you present so the charts
and stats look full.

---

## 6. How to show Firebase (the cloud database)

This is the part that proves the app uses a real database.

✅ **Everyone on the team has been added to the Firebase project**, so you can each open
the console with your **own Google account** — no extra setup needed.

**Open the database console:**
1. Sign in to https://console.firebase.google.com with the Google (Gmail) account you gave to Shi Kaiyan
2. Open the project **des3113**
3. Left menu → **Build → Firestore Database**, or use this direct link:
   👉 https://console.firebase.google.com/project/des3113-7d1fe/firestore/data
4. Open the **`transactions`** collection

**Demo the realtime sync (do this live in the presentation):**
- Add a new entry in the app → it appears in the console **instantly**
- Edit or delete it in the app → the document updates / disappears live
- Bonus: because everyone shares the same project, a record added on **one** laptop shows
  up in **everyone's** app — add on laptop A, refresh laptop B, it's there.

> Can't see the project? Make sure you're signed in with the **exact Gmail** you sent to
> Shi Kaiyan, and accept any "you've been added to a Firebase project" invitation email.

---

## 7. FAQ — "Why does a test say *fake* Firestore?"

The **app uses the real Cloud Firestore.** The automated tests use a helper library
(`fake_cloud_firestore`) that simulates Firestore **in memory**, so the tests can run
quickly without an internet connection. It exists **only in the test files**, never in the
running app.

---

## 8. (Optional) Run the automated tests

Shows the code quality during Q&A:
```bash
flutter test
```
Expected: **`All tests passed!`** (12 tests — model, CRUD provider, and a UI smoke test).

---

## 9. Troubleshooting

| Problem | Fix |
|---------|-----|
| `flutter: command not found` | Flutter isn't installed / not on PATH — see step 2 |
| App opens but data won't save | Check your internet connection (Firestore is online) |
| Data stopped saving after a few weeks | Firestore "test mode" rules expire ~30 days after creation — owner re-publishes the rules in **Firestore → Rules** |
| Errors mentioning `firebase_options` | Run `flutter pub get`, and make sure you launched with `-d chrome` |
| White screen | Wait for the first compile to finish; check the terminal for errors and send them to the team |

---

## 10. Quick command cheat-sheet

```bash
git clone https://github.com/LBBT-God/expense-tracker.git
cd expense-tracker
flutter pub get
flutter run -d chrome     # run the app
flutter test              # run the tests
```

You're ready to demo. Good luck! 🚀
