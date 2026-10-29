# AMC Tracker

@ IOTIQ Innovations

Tracks annual maintenance contracts (AMC) for each client, makes GST quotations, and converts quotations into tax invoices with PDF download and payment tracking. The app is a single `index.html` file hosted on GitHub Pages, with its data stored in Supabase.

## Setup

### 1. Create the database (Supabase)

1. Sign in at [supabase.com](https://supabase.com) and create a project (or open your existing one).
2. Open **SQL Editor → New query**.
3. Paste the contents of `supabase-setup.sql`. Replace `your-email@iotiq.co.in` with your own email address, and add a line for each colleague who should have access.
4. Click **Run**.

### 2. Create logins

1. Go to **Authentication → Users → Add user → Create new user**.
2. Enter the email and a password, and tick **Auto Confirm User**. Do this for each person on the team list.
3. Go to **Authentication → Sign In / Providers** and turn off **Allow new users to sign up**, so nobody can create their own account.

### 3. Connect the app to your project

1. Go to **Project Settings → API**. Copy the **Project URL** and the **anon public** key.
2. Open `index.html`, find `AMC_CONFIG` near the bottom, and replace the two placeholder values:

   ```js
   window.AMC_CONFIG = {
     supabaseUrl: 'https://abcdefghijk.supabase.co',
     supabaseAnonKey: 'eyJhbGciOi...'
   };
   ```

   Use the **anon public** key only. Never put the `service_role` key in this file.

### 4. Publish on GitHub Pages

1. On GitHub, create a new repository, for example `amc-tracker`.
2. Click **Add file → Upload files** and upload `index.html`, `README.md` and `supabase-setup.sql`. Then click **Commit changes**.
3. Go to **Settings → Pages**. Under **Build and deployment**, choose **Deploy from a branch**, select `main` and `/ (root)`, then click **Save**.
4. After a minute or two, the app is live at `https://<your-github-username>.github.io/amc-tracker/`.

## Security

- The publishable (anon) key is designed to be public. It's safe on GitHub because the AMC tables only allow signed-in users whose email is on the `amc_team` list (row level security).
- All AMC tables start with `amc_`, so they stay separate from other tables in the same Supabase project.
- On a free GitHub plan, a Pages site must be a public repository, so anyone can read the code. Your client data stays in Supabase behind the login.
- To give someone access, add their email to the `amc_team` table (Table Editor → amc_team → Insert row) and create a login for them in Authentication → Users.
- To remove someone's access, delete their row from `amc_team` and delete their user in Authentication.
