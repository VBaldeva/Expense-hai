# Ledger — personal money tracker

A single-page money tracker: log expenses, auto-categorize them, set budgets,
add recurring items (rent, SIPs), and see what % of your salary you spend
where, by week/month/quarter/year. Runs entirely in the browser; data lives
in your own free Supabase database, protected by email/password login.

Files:
- `index.html` — the whole app (HTML/CSS/JS, no build step).
- `config.js` — your Supabase project URL + public key (you fill this in).
- `schema.sql` — the two database tables + security rules (run once in Supabase).

## 1. Create a free Supabase project

1. Go to https://supabase.com → sign up → **New project**.
2. Pick a name/password (this DB password is separate from your app login) and a region close to you.
3. Wait ~2 minutes for it to spin up.
4. Left sidebar → **SQL Editor** → **New query** → paste the entire contents of
   `schema.sql` from this repo → **Run**. This creates the `profiles` and
   `months` tables and locks each row to its owner (row-level security), so
   no one but you can read your data even though the key below is public.
5. Left sidebar → **Authentication → Providers** → make sure **Email** is
   enabled (it is by default).
   - Optional but recommended for solo use: **Authentication → Settings** →
     turn **off** "Enable email confirmations", so you can sign in right
     after creating your account without clicking a confirmation email.
6. Left sidebar → **Project Settings → API**. Copy:
   - **Project URL**
   - **anon / public** key (NOT the `service_role` key — never expose that one)

## 2. Fill in config.js

Open `config.js` and paste the two values in:

```js
window.LEDGER_CONFIG = {
  SUPABASE_URL: "https://xxxxxxxx.supabase.co",
  SUPABASE_ANON_KEY: "eyJhbGciOi..."
};
```

The anon key is safe to publish — it's designed to be public. Your data stays
private because of the row-level security policies from `schema.sql`, not
because the key is secret.

## 3. Create your login

Easiest: open `index.html` locally in a browser first (just double-click it)
and try signing in with an email/password that doesn't exist yet — but Supabase
only lets you *sign up* through the dashboard or an API call, not this app's
form (the app only has a sign-in form, to keep it simple and just for you).
So instead, create your one account like this:

- Supabase dashboard → **Authentication → Users → Add user → Create new user**
- Enter your email and a password, and toggle **Auto Confirm User** on.

That's your login for the app — one account, just for you.

## 4. Push the code to GitHub

1. Create a new GitHub repository (public or private both work; on Vercel's
   free tier both are fine — the anon key being visible is expected, see above).
2. Upload these files to the repo root: `index.html`, `config.js`,
   `schema.sql`, `vercel.json`, `README.md`.
   - Via the web UI: repo → **Add file → Upload files** → drag them in → Commit.
   - Or via git:
     ```bash
     git init
     git add .
     git commit -m "Ledger app"
     git branch -M main
     git remote add origin https://github.com/<you>/<repo>.git
     git push -u origin main
     ```

## 5. Deploy on Vercel

**Option A — dashboard (no install needed):**
1. Go to https://vercel.com → sign up/log in (GitHub login is easiest).
2. **Add New… → Project** → **Import** your GitHub repo.
3. Framework preset: leave as **Other** (this is a static site, no build step).
   Leave Build/Output settings blank — `vercel.json` in this repo already
   tells Vercel there's nothing to build.
4. **Deploy**. After ~30 seconds you'll get a URL like
   `https://<repo>.vercel.app`. Sign in with the Supabase account from step 3 above.

**Option B — CLI, if you'd rather deploy from your machine:**
```bash
npm install -g vercel
cd ledger-app        # the folder with index.html
vercel                # first run: link/create the project, deploys a preview
vercel --prod          # promotes to your production URL
```

Either way, every future push to `main` (Option A) or every `vercel --prod`
(Option B) redeploys automatically — there's no build step, so it's fast.

### Custom domain (optional)
Vercel project → **Settings → Domains** → add a domain you own and follow
the DNS instructions shown there. Not needed — the free `.vercel.app` URL
works fine for personal use.

## 5. Optional: lock down auth to just you

Supabase's sign-in form is open to anyone who knows your URL, but without an
account (step 3) they can't get in, and row-level security means even a
second real account couldn't see your data. If you want to be extra sure no
one else can even attempt to sign in:

- **Authentication → Settings → User Signups** → turn off "Allow new user
  signups" (you already created your account, so this just stops anyone else
  from registering one).

## Updating the app later

Edit `index.html` (or ask Claude to), then re-upload/push the changed file.
GitHub Pages redeploys automatically in under a minute.

## Notes

- Free tier limits (Supabase): ~500MB database, project pauses after a week
  with no activity (opening the app wakes it up again, takes a few seconds).
  Fine for personal expense data.
- The in-app PIN lock (Settings → App lock) still works and is a second,
  optional layer on top of your Supabase login — good for locking your phone
  screen without signing all the way out.
- If `config.js` is left with the placeholder values, the app quietly falls
  back to browser-only storage with no login, so you can preview it before
  setting up Supabase.
