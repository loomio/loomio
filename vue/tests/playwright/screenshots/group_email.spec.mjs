import { test, expect } from '../screenshotFixtures.mjs';

async function spotlight(selector) {
  return {
    ...(Array.isArray(selector) ? {selectors: selector} : {selector}),
    padding: 14,
    radius: 14,
    opacity: 0.4,
    outlineWidth: 0
  };
}

test('group_email_address', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.expectText('.action-dock__button--email_group', 'oatmilk-cooperative@localhost');
  await screenshot.capture('groups/email/email_email_button', {
    spotlight: spotlight('.action-dock__button--email_group')
  });
});

test('unreleased_email_actions', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_unreleased_email');
  await page.waitFor('.group-emails-panel');
  await page.expectText('.group-emails-panel', 'Taylor Brooks');
  await page.expectText('.group-emails-panel', 'Returnable bottle collection proposal');
  await screenshot.captureElement('groups/email/email_unreleased_emails', '.group-emails-panel', {
    height: 800,
    spotlight: spotlight([
      '.group-emails-panel__approve',
      '.group-emails-panel__delete'
    ])
  });
});
