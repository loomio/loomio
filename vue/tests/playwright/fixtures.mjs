import { test as base, expect } from '@playwright/test';
import { pageHelper } from './helpers/pageHelper.mjs';

// Loomio asks for confirmation with window.confirm(); accept it as a person
// clicking OK would, so the triggering click can complete.
export const test = base.extend({
  page: async ({ page }, use) => {
    page.on('dialog', dialog => dialog.accept());
    await use(page);
  },
  lmo: async ({ page }, use) => {
    await use(pageHelper(page));
  },
});

export { expect };
