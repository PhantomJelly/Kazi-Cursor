# Kazi

**Work made simple.**

Kazi is a Flutter marketplace for Namibia that connects trade workers with customers who need a job done — electricians, plumbers, gardeners, cleaners, carpenters, handymen, and pool technicians.

Built for student hackathons as a working mobile product: two real user roles, live accounts, and a job-inquiry flow from search to accept or reject.

**Try the web demo:** [https://phantomjelly.github.io/Kazi-Cursor/](https://phantomjelly.github.io/Kazi-Cursor/)

Use **email** sign-up for the most reliable try-out in the browser. Add that Pages URL in Google Cloud (JavaScript origin) and Supabase Auth (site URL / redirect) if you want Google sign-in on the hosted demo.

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
| Sign-in | Email + [Google Sign-In](https://pub.dev/packages/google_sign_in) |
| Motion | [Lottie](https://pub.dev/packages/lottie) |
| Notifications | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) |

**Brand colours:** navy `#03263A`, grey `#A8A8A8`, white.

Schema lives in [`supabase/schema.sql`](supabase/schema.sql).

---

## Demo (hackathon)

Open the [live web demo](https://phantomjelly.github.io/Kazi-Cursor/) (or run locally). Use two accounts — one **worker**, one **customer**.

1. Sign up as a **worker**, complete name and town, then add a trade and photo if you can.
2. Sign out.
3. Sign up as a **customer**.
4. Open **Search**. The worker should appear (pull down to refresh if needed).
5. Open the worker → **Send inquiry** → fill the form.
6. Sign back in as the **worker** → **Jobs** → accept or reject.
7. As the **customer**, open **Profile** to see the status. If accepted, contact details are shown.

Hot restart (`R` in the Flutter terminal) after splash or asset changes.

For judges: **email sign-up** is the reliable path on the hosted demo. If Google sign-in fails in the browser, the Pages origin is not on the Google OAuth client yet.

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
