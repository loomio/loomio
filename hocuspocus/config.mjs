export function authUrlFromEnv(env = process.env) {
  const configuredAppUrl = env.PRIVATE_APP_URL || env.APP_URL || env.PUBLIC_APP_URL;
  let appUrl = configuredAppUrl;

  if (!appUrl && env.RAILS_ENV === 'production') {
    if (!env.CANONICAL_HOST) {
      throw new Error('Hocuspocus requires PRIVATE_APP_URL, APP_URL, PUBLIC_APP_URL, or CANONICAL_HOST in production');
    }
    appUrl = `https://${env.CANONICAL_HOST}`;
  }

  appUrl ||= `http://localhost:${env.CANONICAL_PORT || 8080}`;
  return new URL('/api/hocuspocus', appUrl).toString();
}
