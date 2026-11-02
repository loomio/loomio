import { test as e2eTest, expect as playwrightExpect } from './fixtures.mjs';
import { manualScreenshot } from './helpers/manualScreenshot.mjs';

const catalog = Boolean(globalThis.__manualScreenshotCatalog);

// docs/help/screenshot_catalog.mjs imports the screenshot specs with a
// catalog collector installed, then runs each test body against stubs to learn
// which images it captures without opening a browser.
// The collector is replaced for each spec, so read it when a test is declared.
const catalogTest = catalog && Object.assign((title, run) => globalThis.__manualScreenshotCatalog.tests.push({ title, run }), {
  describe: (title, body) => body(),
  beforeEach() {},
  afterEach() {},
});

export const test = catalogTest || e2eTest.extend({
  manual: async ({ page }, use) => {
    await use(manualScreenshot(page));
  },
});

// Assertions are inert while cataloguing; every matcher accepts any value.
let inertExpect;
inertExpect = new Proxy(function() { return inertExpect; }, {
  get(target, property) { return property === 'then' ? undefined : inertExpect; }
});

export const expect = catalog ? inertExpect : playwrightExpect;
