# Hosting and environment variables

The application does not require a Replit domain. It can run on a standard
Node.js host with PostgreSQL, such as a Hostinger VPS or Node.js hosting plan.

## Required environment variables

Copy `.env.example` to your hosting provider's environment-variable panel and
replace the placeholder values:

- `DATABASE_URL`: any reachable PostgreSQL database
- `ADMIN_USERNAME` and `ADMIN_PASSWORD`: the admin login
- `SESSION_SECRET`: a long random value
- `NODE_ENV=production`
- `PORT`: supplied by the host when applicable

## Media storage

The current upload adapter uses Replit App Storage through these variables:

- `DEFAULT_OBJECT_STORAGE_BUCKET_ID`
- `PRIVATE_OBJECT_DIR`
- `PUBLIC_OBJECT_SEARCH_PATHS`

Those variables are not Hostinger credentials and will not work outside the
Replit environment by themselves. If the app is moved fully to another host,
use an S3-compatible object-storage provider and replace the storage adapter
with that provider's SDK/API. Do not put storage keys in GitHub.

## Deployment

- Build: `pnpm install --frozen-lockfile && pnpm build`
- Web frontend: serve `artifacts/top-quality-prospect/dist/public`.
- API: run `pnpm --filter @workspace/api-server run start`.
- PostgreSQL and object storage must be reachable from the deployed API.
- Configure all environment variables in the host dashboard, not in committed
  files.

## Hostinger

On a Hostinger VPS or Node.js plan, use a reverse proxy to send `/api` requests
to the API process and serve the compiled web directory for all other paths.
The frontend and API must share the same public domain so admin session cookies
and relative `/api` requests work correctly.

## Vercel

The frontend can be deployed as a static Vite build. The current Express API is
not a Vercel Serverless Function, so deploying the whole product to Vercel
requires a serverless API adapter (or hosting the API separately) and an
external PostgreSQL/object-storage service.