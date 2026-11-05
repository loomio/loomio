// docs/help/screenshot_catalog.mjs runs the screenshot specs against stub
// pages to list their images. It runs while the production image builds the
// help site, where @playwright/test is not installed, so load Playwright only
// outside the catalog.
const catalog = Boolean(globalThis.__manualScreenshotCatalog);
const playwright = catalog ? null : await import('@playwright/test');

export const test = catalog ? null : playwright.test.extend({
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

// In the catalog, assertions, including those in shared helpers, are inert:
// every matcher accepts any value at once.
let inertExpect;
inertExpect = new Proxy(function() { return inertExpect; }, {
  get(target, property) { return property === 'then' ? undefined : inertExpect; }
});

export const expect = catalog ? inertExpect : playwright.expect;
