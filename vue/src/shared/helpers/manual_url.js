import locales from '../../../../docs/locales.yml';

const manualLocales = Object.fromEntries(Object.entries(locales)
  .filter(([, settings]) => settings.published)
  .map(([code, settings]) => [settings.app_locale || code, code]));

// App locale names can differ from documentation URL directories. Policies
// and the changelog remain English; unsupported languages use English too.
export function manualUrl(path, appLocale) {
  const page = path.replace(/^\/?en\//, '').replace(/^\//, '');
  const translated = page.startsWith('guides/') ||
    (page.startsWith('user_manual/') && !page.startsWith('user_manual/changelog'));
  const locale = translated ? (manualLocales[appLocale] || 'en') : 'en';
  return `https://www.loomio.com/docs/${locale}/${page}`;
}
