const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

const SUGGESTIONS = '.v-overlay--active .v-list:has(.recipients-autocomplete-suggestion)';

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
  page.execute("document.querySelector('.topic-item__load-more button')?.click()");
  page.waitFor('.poll-created');
  page.expectText('.poll-created', 'Run a six-week returnable bottle trial');
}

function openAddVoters(page, invitePoll = true, height = 700) {
  page.resizeWindow(1100, height);
  if (invitePoll) openInvitePoll(page); else openRunningPoll(page);
  page.clickAndWait('.action-dock__button--announce_poll', '.poll-members-form');
}

function chooseAudience(page, label) {
  page.click('.poll-members-form .recipients-autocomplete input[type="text"]');
  page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
  page.execute(`Array.from(document.querySelectorAll('.v-overlay--active .recipients-autocomplete-suggestion--group')).find(el => el.textContent.includes(${JSON.stringify(label)})).click()`);
  page.waitFor('.poll-members-form .chip--select-multi');
  page.waitFor('.poll-members-form .common-notifications-count');
}

function invitationMessage(page) {
  page.fillTextarea('.poll-members-form textarea', 'Please confirm these responsibilities by Friday. If you see a gap in the plan, add a comment before voting.');
  page.click('.poll-members-form .v-card-title');
  page.expectNoElement(SUGGESTIONS);
}

function openSpecifiedVotersForm(page) {
  page.loadPath('setup_manual_oatmilk_delegate_poll');
  page.expectText('.context-panel__heading', 'Weekly production schedule');
  page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-type--proposal');
  page.click('.decision-tools-card__template--consent');
  page.waitFor('.poll-common-form');
  page.execute("document.querySelector('.poll-common-settings__specified-voters-only input').click()");
  page.waitFor('.poll-common-settings__specified-voters-only.v-selection-control--dirty');
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'proposal_invite': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    // A taller viewport keeps the suggestions below the field instead of over the dialog title.
    openAddVoters(page, true, 1000);
    page.click('.poll-members-form .recipients-autocomplete input[type="text"]');
    page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
    page.expectText(SUGGESTIONS, 'Delegates of Oatmilk Cooperative');
    page.expectText(SUGGESTIONS, 'Oatmilk Cooperative chat');
    page.expectText(SUGGESTIONS, 'Bottle Trial Board');
    screenshot.captureRegion(
      'polls/manage_voters/proposal_invite',
      ['.poll-members-form', SUGGESTIONS],
      {width: 1100, height: 1000, padding: 24, spotlight: {selectors: ['.poll-members-form .recipients-autocomplete', SUGGESTIONS], padding: 12, radius: 16, opacity: 0.3, outlineWidth: 0}}
    );
  },

  'proposal_invite_members': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openAddVoters(page);
    chooseAudience(page, 'Oatmilk Cooperative');
    invitationMessage(page);
    page.expectText('.poll-members-form .common-notifications-count', '3');
    screenshot.captureRegion(
      'polls/manage_voters/proposal_invite_members',
      ['.poll-members-form'],
      {width: 1100, height: 700, padding: 24, spotlight: spotlight('.poll-members-form .recipients-autocomplete')}
    );
  },

  'proposal_invite_expand': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openAddVoters(page);
    chooseAudience(page, 'Oatmilk Cooperative');
    invitationMessage(page);
    page.click('.poll-members-form .chip--select-multi');
    page.expectText('.poll-members-form .recipients-autocomplete', 'Samira Patel');
    page.execute(`Array.from(document.querySelectorAll('.poll-members-form .chip--select-multi')).find(el => el.textContent.includes('Samira Patel')).classList.add('manual-remove-recipient')`);
    page.click('.poll-members-form .v-card-title');
    screenshot.captureRegion(
      'polls/manage_voters/proposal_invite_expand',
      ['.poll-members-form'],
      {width: 1100, height: 700, padding: 24, spotlight: spotlight('.poll-members-form .recipients-autocomplete')}
    );
    page.click('.manual-remove-recipient .v-chip__close');
    page.expectNoElement('.manual-remove-recipient');
    page.expectCount('.poll-members-form .chip--select-multi', 2);
  },

  'proposal_invite_guest': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openAddVoters(page);
    page.fillIn('.poll-members-form .recipients-autocomplete input[type="text"]', 'Samira');
    page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
    page.execute(`Array.from(document.querySelectorAll('.v-overlay--active .recipients-autocomplete-suggestion')).find(el => el.textContent.includes('Samira Patel')).click()`);
    page.expectText('.poll-members-form .chip--select-multi', 'Samira Patel');
    page.fillIn('.poll-members-form .recipients-autocomplete input[type="text"]', 'advisor@cafecircle.example');
    page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
    page.click('.v-overlay--active .recipients-autocomplete-suggestion');
    page.expectText('.poll-members-form .recipients-autocomplete', 'advisor@cafecircle.example');
    invitationMessage(page);
    screenshot.captureRegion(
      'polls/manage_voters/proposal_invite_guest',
      ['.poll-members-form'],
      {padding: 24, width: 1100, height: 700}
    );
  },

  'invited_people_only': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openSpecifiedVotersForm(page);
    page.execute("const radio = document.querySelector('.poll-common-settings__specified-voters-only'); radio.closest('.v-radio-group').classList.add('manual-who-can-vote')");
    screenshot.captureElement('polls/manage_voters/invited-people-only', '.manual-who-can-vote', {width: 1100, height: 800});
  },

  'invite_voters_subgroup': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openAddVoters(page);
    page.click('.poll-members-form .recipients-autocomplete input[type="text"]');
    page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
    page.execute("const option = Array.from(document.querySelectorAll('.v-overlay--active .recipients-autocomplete-suggestion')).find(el => el.textContent.includes('Bottle Trial Board')); option.classList.add('manual-subgroup-option'); option.closest('.v-overlay__content').style.transform = 'translateY(-40px)'");
    screenshot.captureRegion(
      'polls/manage_voters/invite-voters-subgroup',
      ['.v-overlay--active .v-list'],
      {padding: 12, width: 1100, height: 1200, spotlight: spotlight('.manual-subgroup-option')}
    );
  },

  'proposal_after_start': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openRunningPoll(page);
    page.expectText('.poll-created .action-dock__button--announce_poll', 'Manage voters');
    screenshot.captureRegion('polls/manage_voters/proposal_after_start', ['.poll-created .poll-common-card__title', '.poll-created .action-dock'], {
      width: 1100,
      height: 1800,
      padding: 18,
      clearSelection: true,
      spotlight: spotlight('.poll-created .action-dock__button--announce_poll')
    });
  },

  'proposal_invite_remove': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openAddVoters(page, false);
    page.waitFor('.poll-members-form__list .poll-members-form__remove');
    page.execute("const row = Array.from(document.querySelectorAll('.poll-members-form__list .v-list-item')).find(el => el.textContent.includes('Samira Patel')); row.classList.add('manual-remove-voter-row'); row.querySelector('.poll-members-form__remove').classList.add('manual-remove-voter')");
    page.waitFor('.manual-remove-voter');
    screenshot.captureRegion(
      'polls/manage_voters/proposal_invite_remove',
      ['.poll-members-form'],
      {width: 1100, height: 700, padding: 24, spotlight: spotlight('.manual-remove-voter-row')}
    );
  },

  'proposal_remind': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.resizeWindow(1100, 850);
    openRunningPoll(page);
    page.click('.poll-created .poll-common-vote-form__button--agree');
    page.fillIn('.poll-created .poll-common-vote-form__reason [contenteditable=true]', 'The collection and washing responsibilities are clear.');
    page.click('.poll-created .poll-common-vote-form__submit');
    page.waitFor('.poll-created .poll-common-current-vote');
    page.clickAndWait('.action-dock__button--remind_poll', '.poll-remind');
    page.click('.poll-remind .recipients-autocomplete input[type="text"]');
    page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
    page.click('.v-overlay--active .recipients-autocomplete-suggestion--voters_uncast');
    page.waitFor('.poll-remind .chip--select-multi');
    page.fillTextarea('.poll-remind textarea', 'Please vote by Friday so we can confirm the cafe collection schedule before the trial starts.');
    page.click('.poll-remind .v-card-title');
    test.waitForElementVisible('.poll-remind .recipients-autocomplete .v-field-label--floating');
    test.waitForElementVisible('.poll-remind .v-textarea .v-field-label--floating');
    test.execute(() => {
      const dialog = document.querySelector('.poll-remind');
      const labels = Array.from(document.querySelectorAll('.poll-remind .v-field-label--floating'))
        .filter(label => getComputedStyle(label).visibility === 'visible');
      const clipped = labels.filter(label => {
        const bounds = label.getBoundingClientRect();
        for (let parent = label.parentElement; dialog.contains(parent); parent = parent.parentElement) {
          if (!['hidden', 'clip', 'auto', 'scroll'].includes(getComputedStyle(parent).overflowY)) continue;
          const top = parent.getBoundingClientRect().top + parent.clientTop;
          if (bounds.top < top - 0.5 || bounds.bottom > top + parent.clientHeight + 0.5) return true;
        }
        return false;
      });
      return {count: labels.length, clipped: clipped.map(label => label.textContent.trim())};
    }, [], result => {
      test.assert.equal(result.value.count, 2, 'Both floating field labels are visible');
      test.assert.deepEqual(result.value.clipped, [], 'Floating labels fit inside their dialog containers');
    });
    screenshot.captureRegion('polls/manage_voters/proposal_remind', ['.poll-remind'], {width: 1100, height: 850, padding: 32});
  },

  'proposal_close_early': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openRunningPoll(page);
    page.clickAndWait('.action-dock__button--close_poll', '.confirm-modal');
    screenshot.captureElement('polls/manage_voters/proposal_close_early', '.confirm-modal', {width: 1100, height: 800});
  },

  'proposal_reopen': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_outcome');
    page.waitFor('.poll-created');
    page.clickAndWait('.action-dock__button--reopen_poll', '.poll-common-reopen-modal');
    screenshot.captureElement('polls/manage_voters/proposal_reopen', '.poll-common-reopen-modal', {width: 1100, height: 900});
  }
};
