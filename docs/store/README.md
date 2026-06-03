# Store legal pages — Yaqeen

Files for **App Store** and **Google Play** Support URL and Privacy Policy URL.

## Option A — Notion (fastest)

1. Create a new Notion page titled **Yaqeen App – Support**.
2. Copy everything from [`support.md`](./support.md) and paste into Notion.
3. Click **Share → Publish** → copy the public link → paste into **Support URL** in App Store Connect.
4. Repeat with [`privacy-policy.md`](./privacy-policy.md) for **Privacy Policy URL**.

Replace `support@yaqeen.app` with your real email before publishing.

## Option B — GitHub Pages (free public URLs)

1. Commit the `docs/` folder and push to GitHub.
2. On GitHub: **Settings → Pages → Build from branch `main` → folder `/docs`**.
3. After deploy (~2 min), use:
   - `https://kareemtantawi8.github.io/yaqeen_app/support.html`
   - `https://kareemtantawi8.github.io/yaqeen_app/privacy.html`

## App Store field cheat sheet

See [`app-store-connect.md`](./app-store-connect.md) for Keywords, Copyright, Version, and Privacy questionnaire answers.
