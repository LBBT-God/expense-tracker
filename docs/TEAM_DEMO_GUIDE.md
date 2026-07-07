# 🎥 My Wallet — Live Demo Guide (from zero)

A step‑by‑step script for **every team member** to run the app on their own laptop and
**demonstrate live** that it does full CRUD against a **real Cloud Firestore** database.

> **Repo:** https://github.com/LBBT-God/expense-tracker
> **Firebase project (shared by the whole team):** `des3113-7d1fe`
>
> The whole point: add / edit / delete in the app on the left, and the **Firestore
> console on the right updates in realtime**. Do every change with both windows visible.

---

## 0. What you will show (30‑second intro)

“My Wallet is a Flutter expense tracker. Every record is stored in **Cloud Firestore**, a
real cloud database. I’ll add, edit and delete a record, and you’ll see the database change
**live** each time.”

---

## 1. One‑time setup (do this BEFORE demo day)

Install once, then you never touch it again:

| Tool | Why | Link |
|------|-----|------|
| **Flutter SDK** | builds & runs the app | https://docs.flutter.dev/get-started/install |
| **Git** | downloads the code | https://git-scm.com/downloads |
| **Google Chrome** | we run the app in the browser | usually already installed |

Check Flutter is ready:

```bash
flutter doctor
```

You also need **access to the Firebase console** to show the database:
- Send your **Gmail** to Shi Kaiyan so he adds you to the Firebase project, **and**
- Accept the “you’ve been added to a Firebase project” email.
- (You can run the app without this — but you can’t open the console without it.)

---

## 2. Download the project from GitHub

```bash
git clone https://github.com/LBBT-God/expense-tracker.git
cd expense-tracker
flutter pub get
```

> ✅ **No Firebase setup needed.** `lib/firebase_options.dart` is already in the repo and
> points to our shared project. Everyone’s app reads and writes the **same** cloud database.

---

## 3. Launch the app

```bash
flutter run -d chrome
```

- ⚠️ **Run it in Chrome (web).** Do **not** use the Windows desktop build — it is not set up.
- First run compiles for ~1 minute, then Chrome opens on the **Ledger** (home) screen.
- The app is now **live and connected to Cloud Firestore**.

---

## 4. Open the database next to the app

1. Go to **https://console.firebase.google.com** and sign in with your **added Gmail**.
2. Open project **des3113-7d1fe** → left menu **Build → Firestore Database**.
   - Direct link: https://console.firebase.google.com/project/des3113-7d1fe/firestore/data
3. Click the **`transactions`** collection.
4. **Put the two windows side by side** — app on the left, Firestore console on the right.

**What the fields mean** (so you can explain a document on screen):

| Field | Meaning |
|-------|---------|
| `amount` | the money value |
| `type` | `0` = income, `1` = expense |
| `category` | category index (e.g. Food, Transport…) |
| `title` | category name shown in the app |
| `date` | timestamp (milliseconds) |
| `note` | optional note |
| `id` | the document’s own id |

---

## 5. CREATE — add a record, then show the database

**In the app:**
1. Tap the yellow **Record ( + )** button in the bottom centre.
2. Choose the **Expense** (or **Income**) tab at the top.
3. Tap a **category** (e.g. *Food*).
4. Type an **amount** on the keypad (e.g. `12.50`). *(Optionally add a note / change the date.)*
5. Tap **Save**.
6. 👉 The entry appears immediately in **today’s group** on the Ledger.

**→ Show the database:**
- Switch to the Firestore console → **`transactions`**.
- A **brand‑new document appears instantly**. Click it and point out `amount: 12.5`,
  `title: "Food"`, `type: 1`.
- Say: *“The app wrote this document to the cloud in realtime — nothing is stored only on my laptop.”*

---

## 6. UPDATE — edit the same record, then show the database

**In the app:**
1. On the Ledger, **tap the entry** you just created → the **Detail** screen opens.
2. Tap the **pencil (edit)** icon at the top‑right.
3. The record reopens **pre‑filled** — change the **amount** (e.g. `12.50` → `30.00`).
4. Tap **Save**.
5. 👉 The Ledger now shows the **new amount**.

**→ Show the database:**
- In the console, open the **same document** (same `id`).
- Point out that **`amount` changed to `30`** — it is the *same* document, just updated
  (no new document was created).
- Say: *“Update writes to the same Firestore document via `set()`.”*

---

## 7. DELETE — remove the record, then show the database

**In the app:**
1. Open the entry → **Detail** screen.
2. Tap the **trash** icon at the top‑right (or the red **Delete** button).
3. Confirm in the dialog: **“Delete Record — Are you sure?”** → tap **Delete**.
4. 👉 The entry **disappears** from the Ledger.

**→ Show the database:**
- In the console, the **document is gone** from the `transactions` collection.
- Say: *“Delete removes the document from Firestore via `delete()` — the change is instant
  and synced to every device.”*

---

## 8. (Bonus) prove it’s really shared in the cloud

Because everyone uses the **same** Firestore project:
- Add a record on **laptop A** → ask a teammate to **refresh laptop B** → it’s already there.
- This shows the data lives in the cloud, not on one machine.

---

## 9. Demo‑day checklist

- [ ] Laptop has **internet** (Firestore is online).
- [ ] App running with `flutter run -d chrome`.
- [ ] Firestore console open on the **`transactions`** collection, side by side with the app.
- [ ] A few **sample records already added** so the Ledger and charts don’t look empty.
- [ ] You can do **Create → Update → Delete** and point at the console after each.

---

## 10. Troubleshooting

| Problem | Fix |
|---------|-----|
| `flutter: command not found` | Flutter isn’t installed / not on PATH — see step 1. |
| App opens but data won’t save/delete | Check internet. Or the Firestore **test‑mode rules expired** (~30 days) — ask Shi Kaiyan to re‑publish them in **Firestore → Rules**. |
| Can’t open the Firebase console | Your **Gmail must be added** to the project — send it to Shi Kaiyan. |
| White screen on first run | Wait for the first compile to finish; check the terminal for errors. |
| Errors mentioning `firebase_options` | Run `flutter pub get`, and make sure you launched with `-d chrome`. |

---

## Quick cheat‑sheet

```bash
git clone https://github.com/LBBT-God/expense-tracker.git
cd expense-tracker
flutter pub get
flutter run -d chrome      # run the app in Chrome (web)
```

Then: **Record ( + ) → Save** (Create) · **tap entry → ✏️ edit → Save** (Update) ·
**tap entry → 🗑️ delete → confirm** (Delete) — checking the Firestore console after each. 🚀
