# BBW Forklift Inspection System – Setup Guide

## What you're deploying
- **8 QR codes** (4 forklifts, 1 dock stopper, 3 power walkies)
- Mobile-first inspection form (no login needed for operators)
- Dashboard with login for your team to view records
- Automatic email alerts when equipment fails inspection
- Data stored in Supabase (free tier handles thousands of inspections)

---

## Step 1 – Create GitHub Repo

1. Go to **github.com** → **New Repository**
2. Name it: `bbw-forklift-inspection`
3. Set it to **Public**
4. Click **Create repository**
5. Upload all these files (drag & drop or use GitHub Desktop)

---

## Step 2 – Enable GitHub Pages

1. In your repo → **Settings** → **Pages**
2. Under "Source" select **Deploy from a branch**
3. Branch: **main**, folder: **/ (root)**
4. Click **Save**
5. Wait 2-3 minutes → your site will be live at:
   `https://YOUR_USERNAME.github.io/bbw-forklift-inspection`

---

## Step 3 – Set Up Supabase (free database)

1. Go to **supabase.com** → **Start your project** → Sign up free
2. Click **New Project** → name it `bbw-inspections`
3. Wait for it to provision (~2 min)
4. Go to **SQL Editor** → **New Query**
5. Paste the entire contents of `supabase-setup.sql` and click **Run**
6. Go to **Settings → API**:
   - Copy **Project URL** (looks like `https://xxxxx.supabase.co`)
   - Copy **anon public** key (long string starting with `eyJ...`)

---

## Step 4 – Add Your Supabase Keys

Open `js/supabase-config.js` and replace:

```js
const SUPABASE_URL = 'YOUR_SUPABASE_URL_HERE';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY_HERE';
```

With your actual values, then **push/upload the updated file to GitHub**.

---

## Step 5 – Set Up Email Alerts (EmailJS – free)

1. Go to **emailjs.com** → Sign up free (200 emails/month free)
2. **Add Email Service**:
   - Click **Email Services** → **Add New Service**
   - Choose Gmail (or Outlook/SMTP)
   - Connect your email account
   - Copy the **Service ID**
3. **Create Email Template**:
   - Click **Email Templates** → **Create New Template**
   - Subject: `⚠️ BBW Inspection FAILED – {{equipment_id}}`
   - Body (example):
     ```
     Equipment: {{equipment_id}} – {{equipment_name}}
     Operator: {{operator_name}}
     Shift: {{shift}}
     Date/Time: {{date_time}}
     
     FAILED ITEMS ({{failed_count}}):
     {{failed_items}}
     
     Notes: {{notes}}
     ```
   - Copy the **Template ID**
4. Go to **Account** → copy your **Public Key**
5. In the app: **Dashboard → Settings → EmailJS Configuration**
   - Paste your Public Key, Service ID, Template ID
   - Click **Save EmailJS Config**
6. Add alert email addresses under **Failure Alert Emails**
7. Click **Send Test Email** to verify

---

## Step 6 – Create Dashboard User Accounts

1. In **Supabase → Authentication → Users** → **Invite user**
2. Enter the email for each person who needs dashboard access
3. They'll receive an email to set their password
4. They can then log in at your GitHub Pages URL

---

## Step 7 – Print QR Codes

1. Log into your dashboard
2. Go to **QR Codes** tab
3. Download each QR code PNG (includes equipment label + instructions)
4. Print and laminate, then attach to each piece of equipment
5. Operators scan with their phone camera → inspection form opens instantly (no app needed)

---

## Equipment IDs

| ID | Name |
|----|------|
| FL-01 | Forklift 1 |
| FL-02 | Forklift 2 |
| FL-03 | Forklift 3 |
| FL-04 | Forklift 4 |
| DS-01 | Dock Stopper |
| PW-01 | Power Walkie 1 |
| PW-02 | Power Walkie 2 |
| PW-03 | Power Walkie 3 |

To update model/serial numbers, edit the `EQUIPMENT` array in `js/checklist-data.js`.

---

## File Structure

```
bbw-forklift-inspection/
├── index.html              ← Login page (dashboard access)
├── pages/
│   ├── dashboard.html      ← Inspection records
│   ├── qrcodes.html        ← QR code generator + download
│   ├── settings.html       ← Email alerts + user management
│   └── inspect.html        ← Inspection form (opened via QR)
├── css/
│   ├── main.css            ← Main stylesheet
│   └── inspection.css      ← Form-specific styles
├── js/
│   ├── supabase-config.js  ← ⚠️ PUT YOUR KEYS HERE
│   ├── checklist-data.js   ← All inspection items
│   ├── auth.js             ← Login/register
│   ├── auth-guard.js       ← Dashboard protection
│   ├── inspection.js       ← Form logic + email trigger
│   ├── dashboard.js        ← Records table + filters
│   ├── qrcodes.js          ← QR generation + download
│   └── settings.js         ← Email + user settings
├── supabase-setup.sql      ← Run this in Supabase SQL Editor
└── SETUP.md                ← This file
```

---

## Troubleshooting

**Inspection form shows "Equipment Not Found"**
→ Make sure the QR code URL ends with `?equip=FL-01` (etc.)

**"Failed to save inspection"**
→ Check Supabase URL and key in `supabase-config.js`
→ Make sure you ran the SQL setup script

**Email not sending**
→ Test with the "Send Test Email" button in Settings
→ Check EmailJS dashboard for error logs
→ Confirm Service, Template IDs, and Public Key are correct

**Dashboard won't log in**
→ Create users via Supabase → Authentication → Users → Invite

**QR codes point to wrong URL**
→ The app auto-detects the URL. If it's wrong, hard-code `APP_BASE_URL` in `supabase-config.js`
