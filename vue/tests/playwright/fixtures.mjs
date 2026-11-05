import { test as base, expect as playwrightExpect } from '@playwright/test';

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

// docs/help/screenshot_catalog.mjs runs the screenshot specs against stub
// pages to list their images. Assertions there, including those in shared
// helpers, are inert: every matcher accepts any value at once.
let inertExpect;
inertExpect = new Proxy(function() { return inertExpect; }, {
  get(target, property) { return property === 'then' ? undefined : inertExpect; }
});

export const expect = globalThis.__manualScreenshotCatalog ? inertExpect : playwrightExpect;
