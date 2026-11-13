import { afterEach, describe, expect, it, vi } from 'vitest';

const appConfig = vi.hoisted(() => ({}));
vi.mock('@/shared/services/app_config', () => ({default: appConfig}));
vi.mock('@/shared/services/records', () => ({default: {}}));
vi.mock('@/shared/services/session', () => ({default: {}}));
vi.mock('@/shared/record_store/restful_client', () => ({default: class {}}));
vi.mock('@/shared/services/initial_data', () => ({bootData: {permittedParams: {}}}));
vi.mock('@/i18n', async () => ({
  I18n: {}, dateLocale: (await import('date-fns/locale')).enUS
}));

import boot from '@/shared/helpers/boot';
import { exact } from '@/shared/helpers/format_time';

const DateTimeFormat = Intl.DateTimeFormat;
const timestamp = '2026-11-12T13:00:00.000Z';

afterEach(() => vi.restoreAllMocks());

async function bootWithTimeZone(timeZone) {
  vi.spyOn(Intl, 'DateTimeFormat').mockImplementation(function(locales, options) {
    const formatter = new DateTimeFormat(locales, options);
    if (!options?.timeZone) {
      const resolved = formatter.resolvedOptions();
      vi.spyOn(formatter, 'resolvedOptions').mockReturnValue({...resolved, timeZone});
    }
    return formatter;
  });
  await new Promise(resolve => boot(resolve));
}

describe('browser timezone detection at startup', () => {
  it.each([
    ['Pacific/Auckland', '2026-11-13 02:00'],
    ['America/New_York', '2026-11-12 08:00'],
    ['UTC', '2026-11-12 13:00'],
  ])('keeps the valid timezone %s for date formatting', async (timeZone, formatted) => {
    await bootWithTimeZone(timeZone);

    expect(appConfig.timeZone).toBe(timeZone);
    expect(exact(new Date(timestamp), undefined, 'iso')).toBe(formatted);
  });

  it.each(['Etc/Unknown', 'Invalid/Zone', '', undefined])('uses UTC when the browser reports %j', async timeZone => {
    await bootWithTimeZone(timeZone);

    expect(appConfig.timeZone).toBe('UTC');
    expect(exact(new Date(timestamp), undefined, 'iso')).toBe('2026-11-12 13:00');
  });
});
