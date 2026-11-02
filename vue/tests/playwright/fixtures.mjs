import { test as base, expect } from '@playwright/test';
import { pageHelper } from './helpers/pageHelper.mjs';

// `lmo` is the Loomio page helper. Specs destructure it as `page` so the
// helper vocabulary reads like the original suite; the raw Playwright page is
// available as `page.page`.
export const test = base.extend({
  lmo: async ({ page }, use) => {
    // Nightwatch specs accepted every confirm() with acceptConfirm(); accept
    // dialogs as they open so the triggering click can complete.
    page.on('dialog', dialog => dialog.accept());
    await use(pageHelper(page));
  },
});

export { expect };
