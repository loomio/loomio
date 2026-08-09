const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function openSignIn(page) {
  page.loadPath('setup_manual_oatmilk_signed_out');
  page.clickAndWait('.navbar__sign-in', '.auth-form');
}

function useLightTheme(test) {
  test.chrome.sendDevToolsCommand('Emulation.setEmulatedMedia', {
    features: [{name: 'prefers-color-scheme', value: 'light'}]
  });
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'sign_in_email': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    useLightTheme(test);
    openSignIn(page);
    page.fillIn('.auth-email-form__email input', 'jamie@oatmilk.example');
    screenshot.captureElement('users/signing_in/sign_in_email', '.auth-form', {
      width: 1100,
      height: 1200
    });
  },

  'sign_in_code': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    useLightTheme(test);
    openSignIn(page);
    page.fillInAndEnter('.auth-email-form__email input', 'jamie@oatmilk.example');
    page.waitFor('.auth-signin-form');
    page.click('.auth-signin-form__login-link');
    page.waitFor('.auth-complete');
    screenshot.captureElement('users/signing_in/sign_in_code', '.auth-complete', {
      width: 1100,
      height: 1200
    });
  },

  'sign_in_token': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    useLightTheme(test);
    page.loadPath('setup_manual_oatmilk_login_token');
    page.waitFor('.auth-signin-form__token');
    screenshot.captureElement('users/signing_in/sign_in_token', '.auth-signin-form', {
      width: 1100,
      height: 1200
    });
  }
};
