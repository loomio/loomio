import { expect } from '@playwright/test';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);

export const port = process.env.E2E_PORT || (process.env.RAILS_ENV === 'test' ? '3001' : '8080');
export const baseUrl = `http://localhost:${port}`;
const screenshotLabels = process.env.DOCS_SCREENSHOT_LABELS
  ? require(process.env.DOCS_SCREENSHOT_LABELS) : null;

const WAIT = 8000;

export function scenarioUrl(path) {
  const url = new URL(`${baseUrl}/dev/${path}`);
  if (process.env.DOCS_SCREENSHOT_APP_LOCALE) {
    url.searchParams.set('locale', process.env.DOCS_SCREENSHOT_APP_LOCALE);
  }
  return url.toString();
}

const escapeRegExp = string => string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

// Wraps a Playwright page with the helper vocabulary the Nightwatch specs
// used. Every method is async and must be awaited. Selectors address the first
// match, as Nightwatch did, so specs keep their meaning without strict-mode
// locator errors.
export function pageHelper(page) {
  const first = selector => page.locator(selector).first();

  const helper = {
    page,
    first,

    async resizeWindow(width, height) {
      await page.setViewportSize({ width, height });
    },

    async refresh() {
      await page.reload();
    },

    async refreshAndWait() {
      await page.reload();
      await page.locator('.app-is-booted').waitFor({ state: 'attached', timeout: 20000 });
    },

    async loadPath(path) {
      await page.goto(scenarioUrl(path));
      await page.locator('.app-is-booted').waitFor({ state: 'attached', timeout: 20000 });
    },

    async loadPathNoApp(path) {
      await page.goto(scenarioUrl(path));
    },

    async loadLastEmail() {
      await page.goto(`${baseUrl}/dev/last_email`);
    },

    async goTo(path) {
      await page.goto(`${baseUrl}/${path}`);
    },

    async waitForUrlToContain(string) {
      await expect(page).toHaveURL(new RegExp(escapeRegExp(string)));
    },

    async expectCount(selector, count, wait = WAIT) {
      await expect(page.locator(selector)).toHaveCount(count, { timeout: wait });
    },

    async expectElement(selector, wait = WAIT) {
      await expect(first(selector)).toBeVisible({ timeout: wait });
    },

    async expectNoElement(selector, wait = 1000) {
      await expect(page.locator(selector)).toHaveCount(0, { timeout: wait });
    },

    async click(selector) {
      await first(selector).click();
    },

    async fillRichText(selector, html, wait = WAIT) {
      await first(selector).waitFor({ state: 'attached', timeout: wait });
      await page.evaluate(([selector, html]) => {
        const editor = document.querySelector(selector);
        editor.focus();
        editor.innerHTML = html;
        editor.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText' }));
      }, [selector, html]);
    },

    async fillTextarea(selector, value, wait = WAIT) {
      await first(selector).waitFor({ state: 'attached', timeout: wait });
      await page.evaluate(([selector, value]) => {
        const textarea = document.querySelector(selector);
        const setValue = Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype, 'value').set;
        setValue.call(textarea, value);
        textarea.dispatchEvent(new Event('input', { bubbles: true }));
      }, [selector, value]);
    },

    // Clicks with a DOM click, bypassing overlays that would intercept a
    // pointer click on the first visible match.
    async clickElement(selector, wait = WAIT) {
      await first(selector).waitFor({ state: 'attached', timeout: wait });
      await page.evaluate(selector => {
        const element = Array.from(document.querySelectorAll(selector)).find(candidate => {
          const style = window.getComputedStyle(candidate);
          return candidate.getClientRects().length > 0 && style.visibility !== 'hidden';
        });
        element.click();
      }, selector);
    },

    async clickAndWait(selector, nextSelector, wait = WAIT) {
      await helper.clickElement(selector, wait);
      await helper.waitFor(nextSelector, wait);
    },

    async clickLastElement(selector, wait = WAIT) {
      await first(selector).waitFor({ state: 'attached', timeout: wait });
      await page.evaluate(selector => {
        const elements = Array.from(document.querySelectorAll(selector)).filter(candidate => {
          const style = window.getComputedStyle(candidate);
          return candidate.getClientRects().length > 0 && style.visibility !== 'hidden';
        });
        elements.at(-1).click();
      }, selector);
    },

    async scrollClick(selector) {
      await first(selector).scrollIntoViewIfNeeded();
      await first(selector).click();
    },

    async scrollTo(selector) {
      await first(selector).scrollIntoViewIfNeeded();
    },

    async ensureSidebar() {
      await helper.click('.navbar__sidenav-toggle');
    },

    async ensureTopicNav() {
      if (!(await first('.topic-nav__add-people').isVisible())) {
        await helper.click('.topic-page__open-topic-nav');
      }
    },

    async pause(time = 1000) {
      await page.waitForTimeout(time);
    },

    async debug() {
      await page.pause();
    },

    async mouseOver(selector) {
      await first(selector).hover({ position: { x: 10, y: 10 } });
    },

    async clearField(selector) {
      await first(selector).fill('');
    },

    async clear(selector) {
      await first(selector).fill('');
    },

    // Types like a person so key handlers (mentions, autocomplete) run.
    async fillIn(selector, value) {
      const field = first(selector);
      await field.fill('');
      await field.pressSequentially(String(value));
    },

    async fillInAndEnter(selector, value) {
      await helper.fillIn(selector, value);
      await first(selector).press('Enter');
    },

    async escape() {
      await page.keyboard.press('Escape');
    },

    async execute(script, ...args) {
      return page.evaluate(script, ...args);
    },

    async expectValue(selector, value, wait = WAIT) {
      await expect.poll(() => first(selector).inputValue(), { timeout: wait }).toContain(value);
    },

    async expectText(selector, value, wait = WAIT) {
      if (screenshotLabels) {
        // Translated screenshot runs show interface text in another language,
        // and the label table cannot always predict the exact wording, case
        // or inflection. The English run checks the text strictly; translated
        // runs wait for the element and only report a label they cannot find.
        await helper.waitFor(selector, wait);
        if (!screenshotLabels[value]) { return; }
        const candidates = [value, ...screenshotLabels[value]].map(text => text.toLowerCase());
        const text = (await first(selector).innerText()).toLowerCase();
        if (!candidates.some(candidate => text.includes(candidate))) {
          console.log(`Screenshot text not found in ${selector}: ${value}`);
        }
        return;
      }
      await expect(first(selector)).toContainText(value, { timeout: wait });
    },

    async expectFlash(value, wait = WAIT) {
      await expect(first('.flash-root__message')).toContainText(value, { timeout: wait });
    },

    async expectNoText(selector, value, wait = WAIT) {
      await helper.waitFor(selector, wait);
      await expect(first(selector)).not.toContainText(value, { timeout: wait });
    },

    // Dialogs are accepted by the fixture as they open; this only lets the
    // resulting request settle, matching the Nightwatch helper.
    async acceptConfirm() {
      await helper.pause();
    },

    async signInViaPassword(email, password) {
      if (email) { await helper.fillIn('.auth-email-form__email input', email); }
      await helper.fillIn('.auth-email-form__password input', password);
      await helper.click('.auth-email-form__submit');
    },

    async signInViaEmail(email) {
      await helper.fillIn('.auth-email-form__email input', email);
      await helper.click('.auth-email-form__login-link');
      await helper.click('.auth-email-code-form__submit');
      await helper.expectText('.auth-complete', 'Check your email');
      await helper.loadPath('use_last_login_token');
      await helper.click('.auth-signin-form__submit');
      await helper.expectFlash('Signed in successfully');
    },

    async signUpViaEmail(email = 'new@account.com') {
      await helper.click('.auth-form__create-account');
      await helper.fillIn('.auth-signup-form__email input', email);
      await helper.click('.auth-signup-form__submit');
      await helper.expectElement('.auth-complete');
      await helper.loadPath('use_last_login_token');
      await helper.click('.auth-signin-form__submit');
      await helper.completeAccount();
    },

    async completeAccount(name = 'New Account') {
      await helper.fillIn('.account-completion__name input', name);
      await helper.click('.account-completion__legal-accepted .v-selection-control__wrapper');
      await helper.click('.account-completion__submit');
    },

    async signUpViaInvitation(name = 'New person') {
      await helper.click('.auth-form__create-account');
      await helper.click('.auth-signup-form__submit');
      await helper.completeAccount(name);
    },

    async waitFor(selector, wait = WAIT) {
      if (selector != null) { await first(selector).waitFor({ state: 'visible', timeout: wait }); }
    },

    async waitForPresent(selector, wait = WAIT) {
      if (selector != null) { await first(selector).waitFor({ state: 'attached', timeout: wait }); }
    },

    async waitForElementNotVisible(selector, wait = WAIT) {
      if (selector != null) { await first(selector).waitFor({ state: 'hidden', timeout: wait }); }
    },
  };

  return helper;
}
