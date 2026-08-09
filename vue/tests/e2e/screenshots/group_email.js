const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function spotlight(selector) {
  return {
    ...(Array.isArray(selector) ? {selectors: selector} : {selector}),
    padding: 14,
    radius: 14,
    opacity: 0.4,
    outlineWidth: 0
  };
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'group_email_address': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_group');
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    page.expectText('.action-dock__button--email_group', 'oatmilk-cooperative@localhost');
    screenshot.capture('groups/email/email_email_button', {
      spotlight: spotlight('.action-dock__button--email_group')
    });
  },

  'unreleased_email_actions': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_unreleased_email');
    page.waitFor('.group-emails-panel');
    page.expectText('.group-emails-panel', 'Taylor Brooks');
    page.expectText('.group-emails-panel', 'Returnable bottle collection proposal');
    screenshot.captureElement('groups/email/email_unreleased_emails', '.group-emails-panel', {
      height: 800,
      spotlight: spotlight([
        '.group-emails-panel__approve',
        '.group-emails-panel__delete'
      ])
    });
  }
};
