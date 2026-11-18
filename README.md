# AutoVerse.ai website

Static site (HTML/CSS/JS) + one Cloudflare Pages Function (`/api/inquiry`) backed by D1.

```
src/            index.html, 404.html, assets/style.css, assets/app.js
public/         favicon, logo, og-image, _headers, _redirects (copied as-is)
functions/api/  inquiry.js  (form backend)
scripts/build.mjs  minify + content-hash assets + sitemap/robots
test/           automated tests (npm test)
schema.sql      D1 table
```

## Local development
```
npm install
npm run build        # outputs dist/
npm test             # build + 13 automated checks
npm run dev          # local Pages server (needs D1 binding, see wrangler.toml.example)
```

## Environment variables (Cloudflare Pages → Settings → Variables)
| Name | Type | Required | Purpose |
|---|---|---|---|
| `SITE_URL` | Variable (build) | **Yes** | Your live domain, e.g. `https://autoverse.in` – used for canonical, sitemap, OG tags, schema |
| `DB` | D1 binding | **Yes** | Stores inquiries (see below) |
| `IP_SALT` | Secret | Recommended | Random string; salts hashed IPs used for rate limiting |
| `RESEND_API_KEY`, `NOTIFY_EMAIL`, `FROM_EMAIL` | Secrets/Variables | Optional | Email alert per inquiry via Resend (free tier; needs a verified sender domain) |

No secrets are in the frontend code.

## Deploy on Cloudflare (Pages, Git method – recommended)
1. Push this folder to a GitHub repo.
2. Cloudflare dashboard → **Workers & Pages → Create → Pages → Connect to Git** → choose the repo.
3. Build command: `npm run build` · Build output directory: `dist` · Root: `/`.
4. **Settings → Variables and Secrets**: add `SITE_URL` (Production and Preview) and `IP_SALT`.
5. Create the database: **Storage & Databases → D1 → Create** (`autoverse-db`) → open it → **Console** → paste `schema.sql` → Run.
6. Pages project → **Settings → Bindings → Add → D1 database** → variable name `DB` → select `autoverse-db` (Production and Preview).
7. **Deployments → Retry deployment** so the binding takes effect.

Alternative (direct upload): `npm run build && npx wrangler pages deploy dist --project-name autoverse` (Functions are bundled from `functions/`).

## Custom domain
Pages project → **Custom domains → Set up a domain** → enter it. If the domain's DNS is on Cloudflare, records are added automatically; otherwise add the CNAME shown. HTTPS is issued automatically. Then set `SITE_URL` to the final `https://…` and redeploy.

## After deployment
- **Security → WAF → Rate limiting rules**: add a rule for URI path `/api/inquiry`, 10 requests/10 min per IP (extra layer on top of the built-in limit).
- **SSL/TLS → Edge Certificates**: enable *Always Use HTTPS*.
- Submit `https://your-domain/sitemap.xml` in Google Search Console; create a Google Business Profile.
- Read inquiries: D1 → Console → `SELECT * FROM inquiries ORDER BY id DESC;`

## Maintenance
`npm audit` monthly; `npm update` then `npm test`. Edit content in `src/index.html`; never edit `dist/`.

## GitHub + Cloudflare (auto-deploy on every change)
1. Create a repo on github.com (private is fine). Upload this folder's contents (or `git init && git add . && git commit -m "AutoVerse" && git branch -M main && git remote add origin <repo-url> && git push -u origin main`).
2. Cloudflare → Workers & Pages → Create → Pages → Connect to Git → pick the repo.
3. Build command `npm run build`, output directory `dist`. Do not add a `wrangler.toml` (dashboard settings would stop working).
4. Add the D1 binding `DB`, `SITE_URL`, `IP_SALT` as described above, then redeploy.
5. Custom domain: Pages project → Custom domains → Set up a domain. Set `SITE_URL` to `https://your-domain` and redeploy.
Every `git push` to `main` now redeploys production automatically.
