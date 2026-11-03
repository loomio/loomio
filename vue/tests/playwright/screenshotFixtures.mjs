import { createRequire } from 'node:module';
import { test as e2eTest, expect as playwrightExpect } from './fixtures.mjs';
import { manualScreenshot } from './helpers/manualScreenshot.mjs';

const require = createRequire(import.meta.url);
const appLocale = process.env.DOCS_SCREENSHOT_APP_LOCALE;
const labels = process.env.DOCS_SCREENSHOT_LABELS ? require(process.env.DOCS_SCREENSHOT_LABELS) : null;
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
  page: async ({ page }, use) => {
    // Translated runs load each dev scenario in the screenshot locale, so
    // signed-out and server-rendered pages use it too.
    if (appLocale) {
      await page.route('**/dev/**', route => {
        const url = new URL(route.request().url());
        url.searchParams.set('locale', appLocale);
        return route.continue({ url: url.toString() });
      });
    }
    await use(page);
  },
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

// Checks interface text. English runs check it strictly. Translated runs show
// the label in another language, and the label table cannot always predict the
// exact wording, case or inflection, so they wait for the element and only
// report a label they cannot find.
export async function expectLabel(locator, text) {
  if (catalog) { return; }
  if (!labels) {
    await playwrightExpect(locator.first()).toContainText(text);
    return;
  }
  await playwrightExpect(locator.first()).toBeVisible();
  if (!labels[text]) { return; }
  const candidates = [text, ...labels[text]].map(label => label.toLowerCase());
  const shown = (await locator.first().innerText()).toLowerCase();
  if (!candidates.some(candidate => shown.includes(candidate))) {
    console.log(`Screenshot text not found: ${text}`);
  }
}
