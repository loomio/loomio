import { test as base, expect } from '@playwright/test';

export const test = base.extend({
  // Loomio asks for confirmation with window.confirm(); accept it as a person
  // clicking OK would, so the triggering click can complete.
  page: async ({ page }, use) => {
    page.on('dialog', dialog => dialog.accept());
    await use(page);
  },
  // The snackbar that reports the result of an action.
  flash: async ({ page }, use) => {
    await use(page.locator('.flash-root__message'));
  },
});

export { expect };
