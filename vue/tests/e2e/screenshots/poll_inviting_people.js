const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function spotlight(selector) {
  return {selector, padding: 14, radius: 16, opacity: 0.4, outlineWidth: 0};
}

function openInvitePoll(page) {
  page.loadPath('setup_manual_oatmilk_invite_poll');
  page.waitFor('.poll-created');
  page.expectText('.poll-created', 'Approve the bottle trial responsibilities');
}

function openRunningPoll(page) {
  page.loadPath('setup_manual_oatmilk_discussion');
  page.expectText('.context-panel__heading', 'Returnable bottles for cafe customers');
  page.execute("document.querySelector('.strand-item__load-more button')?.click()");
  page.waitFor('.poll-created');
  page.expectText('.poll-created', 'Run a six-week returnable bottle trial');
}

function openAddVoters(page, invitePoll = true) {
  if (invitePoll) openInvitePoll(page); else openRunningPoll(page);
  page.clickAndWait('.action-dock__button--announce_poll', '.poll-members-form');
}

function chooseAudience(page, label) {
  page.click('.poll-members-form .recipients-autocomplete input');
  page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
  page.execute(`Array.from(document.querySelectorAll('.v-overlay--active .recipients-autocomplete-suggestion')).find(el => el.textContent.includes(${JSON.stringify(label)})).click()`);
  page.waitFor('.poll-members-form .chip--select-multi');
}

function openSpecifiedVotersForm(page) {
  page.loadPath('setup_manual_oatmilk_delegate_poll');
  page.expectText('.context-panel__heading', 'Weekly production schedule');
  page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-type--proposal');
  page.execute("Array.from(document.querySelectorAll('.decision-tools-card__poll-type')).find(el => el.textContent.includes('Consent')).click()");
  page.waitFor('.poll-common-form');
  page.click('.poll-common-settings__specified-voters-only .v-selection-control__wrapper');
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'proposal_invite': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openAddVoters(page);
    screenshot.captureElement('polls/inviting_people/proposal_invite', '.poll-members-form', {width: 1100, height: 1100});
  },

  'proposal_invite_members': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openAddVoters(page);
    chooseAudience(page, 'Oatmilk Cooperative');
    screenshot.captureElement('polls/inviting_people/proposal_invite_members', '.poll-members-form', {width: 1100, height: 1100});
  },

  'proposal_invite_expand': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openAddVoters(page);
    chooseAudience(page, 'Oatmilk Cooperative');
    page.click('.poll-members-form .chip--select-multi');
    page.expectText('.poll-members-form .recipients-autocomplete', 'Samira Patel');
    screenshot.captureElement('polls/inviting_people/proposal_invite_expand', '.poll-members-form', {width: 1100, height: 1200});
  },

  'proposal_invite_guest': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openAddVoters(page);
    page.fillIn('.poll-members-form .recipients-autocomplete input', 'advisor@cafecircle.example');
    page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
    screenshot.captureRegion(
      'polls/inviting_people/proposal_invite_guest',
      ['.poll-members-form .recipients-autocomplete', '.v-overlay--active .v-list'],
      {padding: 12, width: 1100, height: 1000}
    );
  },

  'invited_people_only': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openSpecifiedVotersForm(page);
    page.execute("const radio = document.querySelector('.poll-common-settings__specified-voters-only'); radio.closest('.v-radio-group').classList.add('manual-who-can-vote')");
    screenshot.captureElement('polls/inviting_people/invited-people-only', '.manual-who-can-vote', {width: 1100, height: 800});
  },

  'invite_voters_subgroup': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openAddVoters(page);
    page.click('.poll-members-form .recipients-autocomplete input');
    page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
    page.execute("const option = Array.from(document.querySelectorAll('.v-overlay--active .recipients-autocomplete-suggestion')).find(el => el.textContent.includes('Bottle Trial Board')); option.classList.add('manual-subgroup-option'); option.closest('.v-overlay__content').style.transform = 'translateY(-40px)'");
    screenshot.captureRegion(
      'polls/inviting_people/invite-voters-subgroup',
      ['.v-overlay--active .v-list'],
      {padding: 12, width: 1100, height: 1200, spotlight: spotlight('.manual-subgroup-option')}
    );
  },

  'proposal_after_start': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openRunningPoll(page);
    screenshot.captureElement('polls/inviting_people/proposal_after_start', '.poll-created .action-dock', {width: 1100, height: 700});
  },

  'proposal_invite_remove': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openAddVoters(page, false);
    page.execute("Array.from(document.querySelectorAll('.poll-members-form__list .v-list-item')).find(el => el.textContent.includes('Samira Patel')).querySelector('.membership-dropdown__button').click()");
    page.waitFor('.v-overlay--active .v-list');
    page.execute("Array.from(document.querySelectorAll('.v-overlay--active .v-list-item')).find(el => el.textContent.includes('Remove')).classList.add('manual-remove-voter')");
    screenshot.capture('polls/inviting_people/proposal_invite_remove', {
      width: 1280,
      height: 900,
      spotlight: spotlight('.manual-remove-voter')
    });
  },

  'proposal_remind': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openRunningPoll(page);
    page.clickAndWait('.action-dock__button--remind_poll', '.poll-remind');
    page.click('.poll-remind .recipients-autocomplete input');
    page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
    page.execute("Array.from(document.querySelectorAll('.v-overlay--active .recipients-autocomplete-suggestion')).find(el => el.textContent.includes('Everyone invited to vote')).click()");
    page.waitFor('.poll-remind .chip--select-multi');
    screenshot.captureElement('polls/inviting_people/proposal_remind', '.poll-remind', {width: 1100, height: 900});
  },

  'proposal_close_early': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openRunningPoll(page);
    page.clickAndWait('.action-dock__button--close_poll', '.confirm-modal');
    screenshot.captureElement('polls/inviting_people/proposal_close_early', '.confirm-modal', {width: 1100, height: 800});
  },

  'proposal_reopen': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_outcome');
    page.waitFor('.poll-created');
    page.clickAndWait('.action-dock__button--reopen_poll', '.poll-common-reopen-modal');
    screenshot.captureElement('polls/inviting_people/proposal_reopen', '.poll-common-reopen-modal', {width: 1100, height: 900});
  }
};
