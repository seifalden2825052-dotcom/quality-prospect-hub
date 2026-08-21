# Hosting and environment variables

The application has no runtime dependency on Replit. It can run on a standard
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

Images and videos uploaded through the admin panel are stored on the Node.js
server's local disk. Set `MEDIA_STORAGE_DIR` to a writable, persistent
directory outside your deployment/release directory, for example:

```text
/home/USERNAME/tqp-media
```

Do not use a temporary directory, and make sure the Node.js process user can
read and write the directory. Back up this folder along with the database.

## Deployment

- Use Node.js `20.19+` and pnpm `11.22.0` on the Hostinger application.
- Install dependencies: `CI=true pnpm run hostinger:install`
- Build: `CI=true corepack pnpm build`
- Create/update the PostgreSQL tables: `pnpm db:push`
- Start the full website and API: `pnpm start`
- PostgreSQL must be reachable from the deployed API.
- Configure all environment variables in the host dashboard, not in committed
  files.

## Hostinger

On a Hostinger VPS or Node.js plan, set the startup command to:

```bash
corepack pnpm start
```

The API serves the compiled frontend automatically after `pnpm build`, so the
website, admin panel, certificate verification, Pages editor, and media routes
all run from one Node.js process and one public domain. If Hostinger asks for a
port, use the `PORT` environment variable it provides.

The dedicated install command is intentional. Some Hostinger build directories
remove the executable bit from pnpm's esbuild binary; the script restores it
before running esbuild's postinstall check.

## Moving the existing database

Before shutting down the Replit version, run this locally against its current
database:

```bash
pnpm data:export
```

It creates `data/tqp-data-export.json`, which is intentionally ignored by Git.
Copy that file to the Hostinger project, configure its new `DATABASE_URL`, run
`pnpm db:push`, then run:

```bash
pnpm data:import
```

This transfers certificates and dynamic Pages. Copy any existing uploaded media
files separately into `MEDIA_STORAGE_DIR` before switching the domain.

## Vercel

The frontend can be deployed as a static Vite build. The current Express API is
intended for a persistent Node.js host such as Hostinger Node.js/VPS. Vercel
would require a serverless API adapter and external persistent media storage.