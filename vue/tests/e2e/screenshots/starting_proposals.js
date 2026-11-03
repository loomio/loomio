const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');
const richText = require('../helpers/oatmilkRichText');

function openTemplates(page) {
  page.loadPath('setup_manual_oatmilk_formatting?key=0');
  page.expectText('.context-panel__heading', 'Returnable bottles for cafe customers');
  page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-types');
  page.waitFor('.decision-tools-card__template--consent');
}

function openProposalForm(page) {
  openTemplates(page);
  page.click('.decision-tools-card__template--consent');
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
    const heading = document.querySelector('.poll-common-form .poll-common-form__options-heading');
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
  page.execute("document.querySelector('.topic-item__load-more button')?.click()");
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
      'polls/settings/proposal_templates',
      '.actions-panel',
      {width: 1280, height: 1000}
    );
  },

  'proposal_new': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openProposalForm(page);
    page.click('.poll-common-form > .v-card-title');
    page.waitFor('.poll-common-form__more-settings');
    // Frame the complete live form without including the tabs above it.
    page.execute(`
      const form = document.querySelector('.poll-common-form');
      const frame = document.createElement('div');
      frame.className = 'manual-proposal-new-capture';
      Object.assign(frame.style, {
        padding: '16px', margin: '-16px', background: 'white'
      });
      form.before(frame);
      frame.append(form);
    `);
    screenshot.captureElement(
      'polls/settings/proposal_new',
      '.manual-proposal-new-capture',
      {width: 1100, height: 2400, clearSelection: true}
    );
  },

  'vote_options': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.resizeWindow(800, 1800);
    openProposalForm(page);
    markOptions(page);
    page.waitFor('.poll-common-form__add-option-btn');
    screenshot.captureRegion(
      'polls/settings/vote_options',
      ['.manual-options-heading', '.manual-options-list', '.poll-common-form__add-option-btn'],
      {width: 800, height: 1800, padding: 16, scrollSelector: '.manual-options-heading', clearSelection: true}
    );
  },

  'proposal_edit_option': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openProposalForm(page);
    markOptions(page);
    page.clickAndWait('.manual-options-list .poll-common-form__edit-option', '.poll-common-option-form');
    screenshot.captureElement(
      'polls/settings/proposal_edit_option',
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
      'polls/settings/settings_advanced',
      '.poll-common-form .v-expansion-panel',
      {width: 1100, height: 1600}
    );
  },

  'vote_reason_options': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openProposalForm(page);
    page.clickAndWait('.poll-common-form__more-settings', '.poll-common-form .v-expansion-panel-text');
    page.click('.poll-common-form__stance-reason-required .v-field');
    page.waitFor('.v-overlay--active .v-list');
    page.execute(`
      const wrapper = document.createElement('div');
      wrapper.className = 'manual-vote-reason-options-capture';
      Object.assign(wrapper.style, {
        position: 'fixed', top: '0', left: '0', width: '720px', zIndex: '9999',
        padding: '24px', background: 'white'
      });
      wrapper.append(
        document.querySelector('.poll-common-form__stance-reason-required').cloneNode(true),
        document.querySelector('.v-overlay--active .v-list').cloneNode(true)
      );
      document.body.append(wrapper);
    `);
    screenshot.captureElement(
      'polls/settings/vote_reason_options',
      '.manual-vote-reason-options-capture',
      {width: 900, height: 900}
    );
  },

  'proposal_edit': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.resizeWindow(800, 2400);
    openPoll(page);
    page.execute("document.querySelector('.poll-created').scrollIntoView({block: 'center'})");
    page.clickAndWait('.poll-created .action-menu--btn', '.v-overlay--active .action-dock__button--save_as_template');
    page.expectText('.v-overlay--active .action-dock__button--save_as_template', 'Save as template');
    screenshot.captureRegion(
      'polls/settings/proposal_edit',
      ['.poll-created', '.v-overlay--active .v-list'],
      {
        padding: 16,
        width: 800,
        height: 2400,
        clearSelection: true,
        spotlight: {selectors: ['.poll-created .action-menu--btn', '.v-overlay--active .v-list'], padding: 12, radius: 16, opacity: 0.4, outlineWidth: 0}
      }
    );
  },

  'proposal_notification_history': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openPollMenu(page);
    page.clickAndWait('.v-overlay--active .action-dock__button--notification_history', '.modal-launcher .v-card');
    page.expectText('.modal-launcher .v-card', 'Poll notification history');
    screenshot.captureElement(
      'polls/settings/proposal_notification_history',
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
      'polls/settings/proposal_delete',
      '.confirm-modal',
      {width: 1100, height: 800}
    );
  },

  'proposal_print': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openPoll(page);
    page.waitFor('.topic-sidebar .action-dock__button--export_thread');
    page.click('.topic-sidebar .action-dock__button--export_thread');
    page.waitForUrlToContain('export=1');
    page.waitFor('body');
    screenshot.capture('polls/settings/proposal_print', {
      width: 1280,
      height: 1200
    });
  }
};
