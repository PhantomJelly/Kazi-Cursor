# Kazi

**Work made simple.**

Kazi is a Flutter marketplace for Namibia that connects trade workers with customers who need a job done — electricians, plumbers, gardeners, cleaners, carpenters, handymen, and pool technicians.

Built for student hackathons as a working mobile product: two real user roles, live accounts, and a job-inquiry flow from search to accept or reject.

**Live demo:** [https://phantomjelly.github.io/Kazi-Cursor/](https://phantomjelly.github.io/Kazi-Cursor/)  
**Source:** [https://github.com/PhantomJelly/Kazi-Cursor](https://github.com/PhantomJelly/Kazi-Cursor)

Sign up with **email**. Google sign-in is turned off. Use **Settings → Log out** to return to the sign-in page.

---

## The problem

Finding a reliable tradesperson in Namibia is often word-of-mouth, Facebook posts, or a phone number on a shop wall. Customers struggle to compare workers. Workers struggle to get visible, fairly.

Kazi gives both sides one place to meet: customers search by trade and town; workers show their skills, photos, and certificates; jobs go out as inquiries instead of unstructured chats.

## Who it’s for

| Role | What they do |
| --- | --- |
| **Customer** | Search workers, view a profile, send a job inquiry, see accept/reject, then contact the worker |
| **Worker** | Build a profile (trade, experience, bio, portfolio, verification, certificates), receive jobs, accept or decline with a reason |

---

## Tech stack

| Layer | Choice |
| --- | --- |
| App | [Flutter](https://flutter.dev) (Dart 3.13+) |
| Backend | [Supabase](https://supabase.com) — Auth, Postgres, Storage, Realtime |
| Sign-in | Email (Supabase Auth) |
| Motion | [Lottie](https://pub.dev/packages/lottie) |

**Brand colours:** navy `#03263A`, grey `#A8A8A8`, white.

Schema lives in [`supabase/schema.sql`](supabase/schema.sql).

---

## Demo (hackathon)

Open the [live web demo](https://phantomjelly.github.io/Kazi-Cursor/) (or run locally). Create two **email** accounts — one **worker**, one **customer**.

1. Sign up as a **worker**, complete name and town, then add a trade and photo if you can.
2. Open **Settings → Log out** (you should land on the sign-in page).
3. Sign up as a **customer**.
4. Open **Search**. The worker should appear (pull down to refresh if needed).
5. Open the worker → **Send inquiry** → fill the form.
6. Sign back in as the **worker** → **Jobs** → accept or reject.
7. As the **customer**, open **Profile** to see the status. If accepted, contact details are shown.

Hot restart (`R` in the Flutter terminal) after splash or asset changes.

For judges: use **email** sign-up on the hosted demo. If a tab was already open, hard-refresh (Ctrl+Shift+R) or use a private window so you are not on a cached old build.

---

## Run locally

### Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable, 3.16+ recommended)
- Android Studio / an Android emulator, **or** Chrome for web
- A [Supabase](https://supabase.com) project (this repo is already wired to one for development)

```bash
git clone https://github.com/PhantomJelly/Kazi-Cursor.git
cd Kazi-Cursor
flutter pub get
flutter run
```

Target a specific device:

```bash
flutter devices
flutter emulators --launch <emulator_id>
flutter run -d emulator-5554
# or
flutter run -d chrome
```

---

## What’s next

Ideas if we keep building after the hackathon:

- Live worker search filters (distance, availability)
- In-app messaging (not only phone / WhatsApp / email)
- Push notifications (FCM) for job updates
- Tighter inquiry permissions so a worker only sees their own jobs on the server
- Ratings after a job is done
