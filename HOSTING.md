# Hosting and environment variables

The application is designed to be portable between Replit, Hostinger, Vercel,
and other Node.js/PostgreSQL hosts. It does not require a Replit domain.

## Required environment variables

Copy `.env.example` to your hosting provider's environment-variable panel and
replace the placeholder values:

- `DATABASE_URL`: any reachable PostgreSQL database
- `ADMIN_USERNAME` and `ADMIN_PASSWORD`: the admin login
- `SESSION_SECRET`: a long random value
- `NODE_ENV=production`
- `PORT`: supplied by the host when applicable

## Media storage

The current upload adapter uses Replit App Storage through the following
variables:

- `DEFAULT_OBJECT_STORAGE_BUCKET_ID`
- `PRIVATE_OBJECT_DIR`
- `PUBLIC_OBJECT_SEARCH_PATHS`

Those variables are not Hostinger credentials and are not portable by
themselves. If the app is moved fully to Hostinger or Vercel, use an
S3-compatible object-storage provider and replace the storage adapter with that
provider's SDK/API. Do not put storage keys in GitHub.

## Deployment

- Web frontend: build and serve the `artifacts/top-quality-prospect` artifact.
- API: run the `artifacts/api-server` artifact.
- PostgreSQL and object storage must be reachable from the deployed API.
- Configure all environment variables in the host dashboard, not in committed
  files.