const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function openGroupMenu(page) {
  page.loadPath('setup_manual_oatmilk_chatbot');
  page.waitFor('.group-page');
  page.clickAndWait('.group-page .action-menu--btn', '.v-overlay--active .v-list');
}

function openChatbots(page) {
  openGroupMenu(page);
  page.execute("Array.from(document.querySelectorAll('.v-overlay--active .v-list-item')).find(el => el.textContent.includes('Chat integrations')).click()");
  page.waitFor('.chatbot-list');
}

function openAddMenu(page) {
  openChatbots(page);
  page.clickAndWait('.chatbot-list .action-menu--list-item', '.v-overlay--active .v-list');
}

function openPoll(page) {
  page.loadPath('setup_manual_oatmilk_chatbot?view=poll');
  page.waitFor('.poll-created');
}

function openInvite(page) {
  openPoll(page);
  page.clickAndWait('.action-dock__button--announce_poll', '.poll-members-form');
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'loomio-group-settings': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openGroupMenu(page);
    screenshot.capture('integrations/chatbots/loomio-group-settings', {
      width: 1280,
      height: 1000,
      spotlight: '.v-overlay--active .action-dock__button--chatbots'
    });
  },

  'loomio-settings-chatbots': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openChatbots(page);
    screenshot.captureElement('integrations/chatbots/loomio-settings-chatbots', '.chatbot-list', {width: 1100, height: 1300});
  },

  'loomio-chatbot-form': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openAddMenu(page);
    page.execute("Array.from(document.querySelectorAll('.v-overlay--active .v-list-item')).find(el => el.textContent.trim() === 'Slack').click()");
    page.waitFor('.chatbot-matrix-form');
    page.fillIn('.chatbot-matrix-form input', 'Oatmilk Cooperative chat');
    screenshot.captureElement('integrations/chatbots/loomio-chatbot-form', '.chatbot-matrix-form', {width: 1100, height: 2000});
  },

  'invite_button_on_proposal': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openPoll(page);
    screenshot.captureElement('integrations/chatbots/invite_button_on_proposal', '.poll-created', {
      width: 1100,
      height: 1800,
      spotlight: '.action-dock__button--announce_poll'
    });
  },

  'invite_to_vote_1': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openInvite(page);
    page.click('.poll-members-form .recipients-autocomplete input');
    page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
    page.execute("Array.from(document.querySelectorAll('.v-overlay--active .recipients-autocomplete-suggestion')).find(el => el.textContent.includes('Oatmilk Cooperative chat')).classList.add('manual-chatbot-recipient')");
    screenshot.captureRegion(
      'integrations/chatbots/invite_to_vote_1',
      ['.poll-members-form .recipients-autocomplete', '.v-overlay--active .v-list'],
      {width: 1100, height: 1300, padding: 16, spotlight: '.manual-chatbot-recipient'}
    );
  },

  'invite_to_vote_2': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openInvite(page);
    page.click('.poll-members-form .recipients-autocomplete input');
    page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
    page.execute("Array.from(document.querySelectorAll('.v-overlay--active .recipients-autocomplete-suggestion')).find(el => el.textContent.includes('Oatmilk Cooperative chat')).click()");
    page.waitFor('.poll-members-form .chip--select-multi');
    screenshot.captureElement('integrations/chatbots/invite_to_vote_2', '.poll-members-form', {width: 1100, height: 1400});
  },

  'chatbot_enable_automatic_notifications': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openChatbots(page);
    page.clickAndWait('.chatbot-list .v-list-item', '.chatbot-matrix-form');
    screenshot.captureElement('integrations/chatbots/chatbot_enable_automatic_notifications', '.chatbot-matrix-form', {
      width: 1100,
      height: 2100,
      spotlight: {selectors: ['.webhook-form__include-body', '.webhook-form__event-kind']}
    });
  },

  'loomio-add-matrix-bot': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openAddMenu(page);
    screenshot.captureRegion(
      'integrations/matrix/loomio-add-matrix-bot',
      ['.chatbot-list', '.v-overlay--active .v-list'],
      {width: 1100, height: 1500, padding: 16, spotlight: '.v-overlay--active .action-dock__button--matrix'}
    );
  },

  'loomio-matrix-bot-form': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openAddMenu(page);
    page.execute("Array.from(document.querySelectorAll('.v-overlay--active .v-list-item')).find(el => el.textContent.trim() === 'Matrix').click()");
    page.waitFor('.chatbot-matrix-form');
    screenshot.captureElement('integrations/matrix/loomio-matrix-bot-form', '.chatbot-matrix-form', {width: 1100, height: 2100});
  }
};
