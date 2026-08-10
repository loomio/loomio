const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');
const richText = require('../helpers/oatmilkRichText');

function openTemplates(page) {
  page.loadPath('setup_manual_oatmilk_formatting?key=0');
  page.expectText('.context-panel__heading', 'Returnable bottles for cafe customers');
  page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-types');
  page.expectText('.decision-tools-card__poll-types', 'Consent');
}

function openProposalForm(page) {
  openTemplates(page);
  page.execute("Array.from(document.querySelectorAll('.decision-tools-card__poll-type')).find(el => el.textContent.includes('Consent')).click()");
  page.waitFor('.poll-common-form-fields__title input');
  page.fillIn('.poll-common-form-fields__title input', 'Approve the returnable bottle trial plan');
  page.fillRichText(
    '.poll-common-form-fields__details [contenteditable=true]',
    richText.context('new-proposal', [
      'Approve a six-week returnable bottle trial with three cafe partners and one collection from each cafe every week.',
      'Before launch, confirm the collection schedule, washing checks, bottle deposit guidance, and named responsibilities.',
      'At the end of the trial, review return rates, cleaning time, damaged bottles, and transport costs.'
    ])
  );
}

function markOptions(page) {
  page.execute(`
    const heading = Array.from(document.querySelectorAll('.poll-common-form .text-body-large'))
      .find(el => el.textContent.trim() === 'Options');
    heading.classList.add('manual-options-heading');
    heading.nextElementSibling.classList.add('manual-options-list');
    const options = Array.from(heading.nextElementSibling.querySelectorAll('.v-list-item'));
    options.at(-1).classList.add('manual-option-last');
  `);
  page.waitFor('.manual-options-list');
}

function openPoll(page) {
  page.loadPath('setup_manual_oatmilk_discussion');
  page.expectText('.context-panel__heading', 'Returnable bottles for cafe customers');
  page.execute("document.querySelector('.strand-item__load-more button')?.click()");
  page.waitFor('.poll-created');
  page.expectText('.poll-created', 'Run a six-week returnable bottle trial');
}

function openPollMenu(page) {
  openPoll(page);
  page.click('.poll-created .action-menu--btn');
  page.waitFor('.v-overlay--active .v-list');
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'proposal_templates': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openTemplates(page);
    screenshot.captureElement(
      'polls/starting_proposals/proposal_templates',
      '.actions-panel',
      {width: 1280, height: 1000}
    );
  },

  'proposal_new': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openProposalForm(page);
    page.execute(`
      const form = document.querySelector('.poll-common-form');
      const wrapper = document.createElement('div');
      wrapper.className = 'manual-proposal-new-capture';
      Object.assign(wrapper.style, {
        position: 'fixed', top: '0', left: '0', width: '100%', zIndex: '9999',
        padding: '24px', background: 'white'
      });
      [
        form.querySelector('.v-card-title'),
        form.querySelector('.poll-template-info-panel'),
        form.querySelector('.poll-common-form-fields__title'),
        form.querySelector('.poll-common-form-fields__details')
      ].forEach(el => wrapper.append(el.cloneNode(true)));
      document.body.append(wrapper);
    `);
    page.pause(200);
    screenshot.captureElement(
      'polls/starting_proposals/proposal_new',
      '.manual-proposal-new-capture',
      {width: 1200, height: 1100}
    );
  },

  'vote_options': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openProposalForm(page);
    markOptions(page);
    page.execute(`
      const heading = document.querySelector('.manual-options-heading');
      const list = document.querySelector('.manual-options-list');
      const wrapper = document.createElement('div');
      wrapper.className = 'manual-options-capture';
      Object.assign(wrapper.style, {
        position: 'fixed', top: '0', left: '0', width: '100%', zIndex: '9999',
        padding: '16px', background: 'white'
      });
      wrapper.append(heading.cloneNode(true), list.cloneNode(true));
      document.body.append(wrapper);
    `);
    screenshot.captureElement(
      'polls/starting_proposals/vote_options',
      '.manual-options-capture',
      {width: 1200, height: 1200}
    );
  },

  'proposal_edit_option': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openProposalForm(page);
    markOptions(page);
    page.clickAndWait('.manual-options-list button[title="Edit"]', '.poll-common-option-form');
    screenshot.captureElement(
      'polls/starting_proposals/proposal_edit_option',
      '.poll-common-option-form',
      {width: 1100, height: 1000}
    );
  },

  'settings_advanced': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openProposalForm(page);
    page.clickAndWait('.poll-common-form__more-settings', '.poll-common-form .v-expansion-panel-text');
    screenshot.captureElement(
      'polls/starting_proposals/settings_advanced',
      '.poll-common-form .v-expansion-panel',
      {width: 1100, height: 1600}
    );
  },

  'proposal_edit': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openPollMenu(page);
    screenshot.captureRegion(
      'polls/starting_proposals/proposal_edit',
      ['.poll-created .action-dock', '.v-overlay--active .v-list'],
      {padding: 16, width: 1280, height: 1100}
    );
  },

  'proposal_notification_history': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openPollMenu(page);
    page.clickAndWait('.v-overlay--active .action-dock__button--notification_history', '.modal-launcher .v-card');
    page.expectText('.modal-launcher .v-card', 'Poll notification history');
    screenshot.captureElement(
      'polls/starting_proposals/proposal_notification_history',
      '.modal-launcher .v-card',
      {width: 1100, height: 900}
    );
  },

  'proposal_delete': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openPollMenu(page);
    page.clickAndWait('.v-overlay--active .action-dock__button--discard_poll', '.confirm-modal');
    screenshot.captureElement(
      'polls/starting_proposals/proposal_delete',
      '.confirm-modal',
      {width: 1100, height: 800}
    );
  },

  'proposal_print': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openPoll(page);
    page.waitFor('.thread-sidebar .action-dock__button--export_thread');
    page.click('.thread-sidebar .action-dock__button--export_thread');
    page.waitForUrlToContain('export=1');
    page.waitFor('body');
    screenshot.capture('polls/starting_proposals/proposal_print', {
      width: 1280,
      height: 1200
    });
  }
};
