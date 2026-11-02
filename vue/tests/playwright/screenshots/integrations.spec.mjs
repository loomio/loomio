import { test, expect } from '../screenshotFixtures.mjs';

async function openGroupMenu(page) {
  await page.loadPath('setup_manual_oatmilk_chatbot');
  await page.waitFor('.group-page');
  await page.clickAndWait('.group-page .action-menu--btn', '.v-overlay--active .v-list');
}

async function openChatbots(page) {
  await openGroupMenu(page);
  await page.click('.v-overlay--active .action-dock__button--chatbots');
  await page.waitFor('.chatbot-list');
}

async function openAddMenu(page) {
  await openChatbots(page);
  await page.clickAndWait('.chatbot-list .action-menu--list-item', '.v-overlay--active .v-list');
}

async function openPoll(page) {
  await page.loadPath('setup_manual_oatmilk_chatbot?view=poll');
  await page.waitFor('.poll-created');
}

async function openInvite(page) {
  await openPoll(page);
  await page.clickAndWait('.action-dock__button--announce_poll', '.poll-members-form');
}

test('loomio-group-settings', async ({ lmo: page, manual: screenshot }) => {
  await openGroupMenu(page);
  await screenshot.capture('integrations/chatbots/loomio-group-settings', {
    width: 1280,
    height: 1000,
    spotlight: '.v-overlay--active .action-dock__button--chatbots'
  });
});

test('loomio-settings-chatbots', async ({ lmo: page, manual: screenshot }) => {
  await openChatbots(page);
  await screenshot.captureElement('integrations/chatbots/loomio-settings-chatbots', '.chatbot-list', {width: 1100, height: 1300});
});

test('loomio-chatbot-form', async ({ lmo: page, manual: screenshot }) => {
  await openAddMenu(page);
  await page.click('.v-overlay--active .action-dock__button--slack');
  await page.waitFor('.chatbot-matrix-form');
  await page.fillIn('.chatbot-matrix-form input', 'Oatmilk Cooperative chat');
  await screenshot.captureElement('integrations/chatbots/loomio-chatbot-form', '.chatbot-matrix-form', {width: 1100, height: 2000});
});

test('invite_button_on_proposal', async ({ lmo: page, manual: screenshot }) => {
  await openPoll(page);
  await screenshot.captureRegion('integrations/chatbots/invite_button_on_proposal', ['.poll-created'], {
    width: 1100,
    height: 1800,
    padding: 16,
    spotlight: '.action-dock__button--announce_poll'
  });
});

test('invite_to_vote_1', async ({ lmo: page, manual: screenshot }) => {
  await openInvite(page);
  await page.click('.poll-members-form .recipients-autocomplete input[type="text"]');
  await page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
  await page.execute("Array.from(document.querySelectorAll('.v-overlay--active .recipients-autocomplete-suggestion')).find(el => el.textContent.includes('Oatmilk Cooperative chat')).classList.add('manual-chatbot-recipient')");
  await screenshot.captureRegion(
    'integrations/chatbots/invite_to_vote_1',
    ['.poll-members-form .recipients-autocomplete', '.v-overlay--active .v-list'],
    {width: 1100, height: 1300, padding: 16, spotlight: '.manual-chatbot-recipient'}
  );
});

test('invite_to_vote_2', async ({ lmo: page, manual: screenshot }) => {
  await openInvite(page);
  await page.click('.poll-members-form .recipients-autocomplete input[type="text"]');
  await page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
  await page.execute("Array.from(document.querySelectorAll('.v-overlay--active .recipients-autocomplete-suggestion')).find(el => el.textContent.includes('Oatmilk Cooperative chat')).click()");
  await page.waitFor('.poll-members-form .chip--select-multi');
  await screenshot.captureElement('integrations/chatbots/invite_to_vote_2', '.poll-members-form', {width: 1100, height: 1400});
});

test('chatbot_enable_automatic_notifications', async ({ lmo: page, manual: screenshot }) => {
  await openChatbots(page);
  await page.clickAndWait('.chatbot-list .v-list-item', '.chatbot-matrix-form');
  await screenshot.captureElement('integrations/chatbots/chatbot_enable_automatic_notifications', '.chatbot-matrix-form', {
    width: 1100,
    height: 2100,
    spotlight: {selectors: ['.webhook-form__include-body', '.webhook-form__event-kind']}
  });
});

test('loomio-add-matrix-bot', async ({ lmo: page, manual: screenshot }) => {
  await openAddMenu(page);
  await screenshot.captureRegion(
    'integrations/matrix/loomio-add-matrix-bot',
    ['.chatbot-list', '.v-overlay--active .v-list'],
    {width: 1100, height: 1500, padding: 16, spotlight: '.v-overlay--active .action-dock__button--matrix'}
  );
});

test('loomio-matrix-bot-form', async ({ lmo: page, manual: screenshot }) => {
  await openAddMenu(page);
  await page.click('.v-overlay--active .action-dock__button--matrix');
  await page.waitFor('.chatbot-matrix-form');
  await screenshot.captureElement('integrations/matrix/loomio-matrix-bot-form', '.chatbot-matrix-form', {width: 1100, height: 2100});
});
