import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

async function openGroupMenu(page) {
  await page.goto('/dev/setup_manual_oatmilk_chatbot')
  await expect(page.locator('.group-page').first()).toBeVisible()
  await page.locator('.group-page .action-menu--btn').click()
}

async function openChatbots(page) {
  await openGroupMenu(page);
  await page.locator('.v-overlay--active .action-dock__button--chatbots').click()
  await expect(page.locator('.chatbot-list').first()).toBeVisible()
}

async function openAddMenu(page) {
  await openChatbots(page);
  await page.locator('.chatbot-list .action-menu--list-item').click()
}

async function openPoll(page) {
  await page.goto('/dev/setup_manual_oatmilk_chatbot?view=poll')
  await expect(page.locator('.poll-created').first()).toBeVisible()
}

async function openInvite(page) {
  await openPoll(page);
  await page.locator('.action-dock__button--announce_poll').click()
}

test('loomio-group-settings', async ({ page, manual: screenshot }) => {
  await openGroupMenu(page);
  await screenshot.capture('integrations/chatbots/loomio-group-settings', {
    width: 1280,
    height: 1000,
    spotlight: '.v-overlay--active .action-dock__button--chatbots'
  });
});

test('loomio-settings-chatbots', async ({ page, manual: screenshot }) => {
  await openChatbots(page);
  await screenshot.captureElement('integrations/chatbots/loomio-settings-chatbots', '.chatbot-list', {width: 1100, height: 1300});
});

test('loomio-chatbot-form', async ({ page, manual: screenshot }) => {
  await openAddMenu(page);
  await page.locator('.v-overlay--active .action-dock__button--slack').click()
  await expect(page.locator('.chatbot-matrix-form').first()).toBeVisible()
  await page.locator('.chatbot-matrix-form input').fill('Oatmilk Cooperative chat')
  await screenshot.captureElement('integrations/chatbots/loomio-chatbot-form', '.chatbot-matrix-form', {width: 1100, height: 2000});
});

test('invite_button_on_proposal', async ({ page, manual: screenshot }) => {
  await openPoll(page);
  await screenshot.captureRegion('integrations/chatbots/invite_button_on_proposal', ['.poll-created'], {
    width: 1100,
    height: 1800,
    padding: 16,
    spotlight: '.action-dock__button--announce_poll'
  });
});

test('invite_to_vote_1', async ({ page, manual: screenshot }) => {
  await openInvite(page);
  await page.locator('.poll-members-form .recipients-autocomplete input[type="text"]').click()
  await expect(page.locator('.v-overlay--active .recipients-autocomplete-suggestion').first()).toBeVisible()
  await page.evaluate("Array.from(document.querySelectorAll('.v-overlay--active .recipients-autocomplete-suggestion')).find(el => el.textContent.includes('Oatmilk Cooperative chat')).classList.add('manual-chatbot-recipient')")
  await screenshot.captureRegion(
    'integrations/chatbots/invite_to_vote_1',
    ['.poll-members-form .recipients-autocomplete', '.v-overlay--active .v-list'],
    {width: 1100, height: 1300, padding: 16, spotlight: '.manual-chatbot-recipient'}
  );
});

test('invite_to_vote_2', async ({ page, manual: screenshot }) => {
  await openInvite(page);
  await page.locator('.poll-members-form .recipients-autocomplete input[type="text"]').click()
  await expect(page.locator('.v-overlay--active .recipients-autocomplete-suggestion').first()).toBeVisible()
  await page.evaluate("Array.from(document.querySelectorAll('.v-overlay--active .recipients-autocomplete-suggestion')).find(el => el.textContent.includes('Oatmilk Cooperative chat')).click()")
  await expect(page.locator('.poll-members-form .chip--select-multi').first()).toBeVisible()
  await screenshot.captureElement('integrations/chatbots/invite_to_vote_2', '.poll-members-form', {width: 1100, height: 1400});
});

test('chatbot_enable_automatic_notifications', async ({ page, manual: screenshot }) => {
  await openChatbots(page);
  await page.locator('.chatbot-list .v-list-item').click()
  await screenshot.captureElement('integrations/chatbots/chatbot_enable_automatic_notifications', '.chatbot-matrix-form', {
    width: 1100,
    height: 2100,
    spotlight: {selectors: ['.webhook-form__include-body', '.webhook-form__event-kind']}
  });
});

test('loomio-add-matrix-bot', async ({ page, manual: screenshot }) => {
  await openAddMenu(page);
  await screenshot.captureRegion(
    'integrations/matrix/loomio-add-matrix-bot',
    ['.chatbot-list', '.v-overlay--active .v-list'],
    {width: 1100, height: 1500, padding: 16, spotlight: '.v-overlay--active .action-dock__button--matrix'}
  );
});

test('loomio-matrix-bot-form', async ({ page, manual: screenshot }) => {
  await openAddMenu(page);
  await page.locator('.v-overlay--active .action-dock__button--matrix').click()
  await expect(page.locator('.chatbot-matrix-form').first()).toBeVisible()
  await screenshot.captureElement('integrations/matrix/loomio-matrix-bot-form', '.chatbot-matrix-form', {width: 1100, height: 2100});
});
