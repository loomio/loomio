import { test, expect } from '../screenshotFixtures.mjs';

const chatbotName = 'Oatmilk Cooperative chat';

async function openGroupMenu(page) {
  await page.goto('/dev/setup_manual_oatmilk_chatbot');
  await page.locator('.group-page__actions .action-menu--btn').click();
  await expect(page.locator('.v-overlay--active .action-dock__button--chatbots')).toBeVisible();
}

async function openChatbots(page) {
  await openGroupMenu(page);
  await page.locator('.v-overlay--active .action-dock__button--chatbots').click();
  await expect(page.locator('.chatbot-list__chatbot', { hasText: chatbotName })).toBeVisible();
}

async function openAddMenu(page) {
  await openChatbots(page);
  await page.locator('.chatbot-list .action-menu--list-item').click();
}

async function openPoll(page) {
  await page.goto('/dev/setup_manual_oatmilk_chatbot?view=poll');
  await expect(page.locator('.poll-created')).toBeVisible();
}

// Opens the voter suggestions and returns the chatbot's suggestion.
async function openInviteSuggestions(page) {
  await openPoll(page);
  // Size the window first: resizing while the menu is open leaves it misplaced.
  await page.setViewportSize({ width: 1100, height: 1300 });
  await page.locator('.action-dock__button--announce_poll').click();
  await expect(page.locator('.poll-members-form__list .v-list-item')).toHaveCount(3);
  await page.locator('.poll-members-form .recipients-autocomplete input[type="text"]').click();
  const suggestion = page.locator('.v-overlay--active .recipients-autocomplete-suggestion', { hasText: chatbotName });
  await expect(suggestion).toBeVisible();
  return suggestion;
}

test('loomio-group-settings', async ({ page, manual: screenshot }) => {
  await openGroupMenu(page);
  await screenshot.capture('integrations/chatbots/loomio-group-settings', {
    width: 1280,
    height: 857,
    spotlight: '.v-overlay--active .action-dock__button--chatbots'
  });
});

test('loomio-settings-chatbots', async ({ page, manual: screenshot }) => {
  await openChatbots(page);
  await screenshot.captureElement('integrations/chatbots/loomio-settings-chatbots', '.chatbot-list', { width: 1100, height: 1300 });
});

test('loomio-chatbot-form', async ({ page, manual: screenshot }) => {
  await openAddMenu(page);
  await page.locator('.v-overlay--active .action-dock__button--slack').click();
  await page.locator('.chatbot-matrix-form .webhook-form__name input').fill(chatbotName);
  await screenshot.captureElement('integrations/chatbots/loomio-chatbot-form', '.chatbot-matrix-form', { width: 1100, height: 2000 });
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
  const suggestion = await openInviteSuggestions(page);
  // The capture helper takes selectors; give the chatbot's suggestion one.
  await suggestion.evaluate(element => element.classList.add('manual-chatbot-recipient'));
  await screenshot.captureRegion(
    'integrations/chatbots/invite_to_vote_1',
    ['.poll-members-form', '.v-overlay--active .v-list'],
    { width: 1100, height: 1300, padding: 16, spotlight: '.manual-chatbot-recipient' }
  );
});

test('invite_to_vote_2', async ({ page, manual: screenshot }) => {
  const suggestion = await openInviteSuggestions(page);
  await suggestion.click();
  await expect(page.locator('.poll-members-form .chip--select-multi', { hasText: chatbotName })).toBeVisible();
  await screenshot.captureElement('integrations/chatbots/invite_to_vote_2', '.poll-members-form', { width: 1100, height: 1400 });
});

test('chatbot_enable_automatic_notifications', async ({ page, manual: screenshot }) => {
  await openChatbots(page);
  await page.locator('.chatbot-list__chatbot', { hasText: chatbotName }).click();
  // One checkbox per event kind; any shows the form has loaded.
  await expect(page.locator('.chatbot-matrix-form .webhook-form__event-kind').first()).toBeVisible();
  await screenshot.captureElement('integrations/chatbots/chatbot_enable_automatic_notifications', '.chatbot-matrix-form', {
    width: 1100,
    height: 2100,
    spotlight: { selectors: ['.webhook-form__include-body', '.webhook-form__event-kind'] }
  });
});

test('loomio-add-matrix-bot', async ({ page, manual: screenshot }) => {
  await openAddMenu(page);
  await expect(page.locator('.v-overlay--active .action-dock__button--matrix')).toBeVisible();
  await screenshot.captureRegion(
    'integrations/matrix/loomio-add-matrix-bot',
    ['.chatbot-list', '.v-overlay--active .v-list'],
    { width: 1100, height: 1500, padding: 16, spotlight: '.v-overlay--active .action-dock__button--matrix' }
  );
});

test('loomio-matrix-bot-form', async ({ page, manual: screenshot }) => {
  await openAddMenu(page);
  await page.locator('.v-overlay--active .action-dock__button--matrix').click();
  await expect(page.locator('.chatbot-matrix-form')).toBeVisible();
  await screenshot.captureElement('integrations/matrix/loomio-matrix-bot-form', '.chatbot-matrix-form', { width: 1100, height: 2100 });
});
