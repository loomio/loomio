const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function spotlight(selector) {
  return {
    selector,
    padding: 14,
    radius: 14,
    opacity: 0.4,
    outlineWidth: 0
  };
}

function openMembers(page, scenario = 'setup_manual_oatmilk_delegates') {
  page.loadPath(scenario);
  page.expectText('.group-page__name', 'Oatmilk Cooperative');
  page.click('.group-page-members-tab');
  page.waitFor('.members-panel');
  page.expectText('.members-panel', 'Samira Patel');
}

function openSamiraMenu(page) {
  openMembers(page, 'setup_manual_oatmilk_group');
  page.execute("Array.from(document.querySelectorAll('.members-panel .v-list-item')).find(el => el.textContent.includes('Samira Patel') && el.querySelector('.membership-dropdown__button')).querySelector('.membership-dropdown__button').click()");
  page.waitFor('.v-overlay .group-actions-dropdown__menu-content');
}

function openProposalForm(page) {
  page.loadPath('setup_manual_oatmilk_delegate_poll');
  page.expectText('.context-panel__heading', 'Weekly production schedule');
  page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-type--proposal');
  page.clickAndWait('.decision-tools-card__poll-type--proposal', '.poll-common-form-fields__title input');
  page.fillIn('.poll-common-form-fields__title input', 'Approve reusable bottle pilot');
  page.fillIn('.poll-common-form-fields__details [contenteditable=true]', 'Invite the cooperative delegates to decide whether to begin the pilot.');
  page.click('.poll-common-settings__specified-voters-only .v-selection-control__wrapper');
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'make_delegate': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openSamiraMenu(page);
    page.expectText('.v-overlay .membership-dropdown__make-delegate', 'Make delegate');
    screenshot.capture('groups/delegated_voters/member_make_delegate', {
      spotlight: spotlight('.v-overlay .membership-dropdown__make-delegate')
    });
  },

  'invited_people_only': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openProposalForm(page);
    page.expectText('.poll-common-form', 'Selected people only');
    page.execute("const heading = document.querySelector('.poll-common-settings__specified-voters-only').closest('.v-radio-group').previousElementSibling; heading.classList.add('manual-who-can-vote'); heading.style.scrollMarginTop = '88px'");
    screenshot.capture('groups/delegated_voters/poll_invited_people_only', {
      height: 560,
      scrollSelector: '.manual-who-can-vote',
      scrollBlock: 'start'
    });
  },

  'invite_delegates': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openProposalForm(page);
    page.click('.poll-common-form__submit');
    page.waitFor('.poll-members-form');
    page.click('.poll-members-form .recipients-autocomplete input');
    page.waitFor('.recipients-autocomplete-suggestion');
    page.pause(300);
    page.execute("Array.from(document.querySelectorAll('.recipients-autocomplete-suggestion')).find(el => el.textContent.includes('Delegates of Oatmilk Cooperative')).classList.add('manual-delegates-option')");
    test.moveToElement('css selector', '.manual-delegates-option', 10, 10);
    screenshot.capture('groups/delegated_voters/poll_invite_delegates_group', {height: 650});
  },

  'filter_delegates': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openMembers(page);
    page.click('.members-panel__filters');
    page.waitFor('.v-overlay .members-panel__filters-delegates');
    screenshot.capture('groups/delegated_voters/members_list_delegates', {
      spotlight: spotlight('.v-overlay .members-panel__filters-delegates')
    });
  }
};
