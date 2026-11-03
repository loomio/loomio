import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

function spotlight(selector) {
  return {
    ...(Array.isArray(selector) ? {selectors: selector} : {selector}),
    padding: 14,
    radius: 14,
    opacity: 0.4,
    outlineWidth: 0
  };
}

test('group_email_address', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await expectLabel(page.locator('.action-dock__button--email_group'), 'oatmilk-cooperative@localhost')
  await screenshot.capture('groups/email/email_email_button', {
    spotlight: spotlight('.action-dock__button--email_group')
  });
});

test('unreleased_email_actions', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_unreleased_email')
  await expectLabel(page.locator('.group-emails-panel'), 'Taylor Brooks')
  await expectLabel(page.locator('.group-emails-panel'), 'Returnable bottle collection proposal')
  await screenshot.captureElement('groups/email/email_unreleased_emails', '.group-emails-panel', {
    height: 800,
    spotlight: spotlight([
      '.group-emails-panel__approve',
      '.group-emails-panel__delete'
    ])
  });
});
