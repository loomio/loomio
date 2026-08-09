const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function openTemplates(page, custom = false) {
  page.loadPath(custom ? 'setup_manual_oatmilk_custom_poll_template' : 'setup_manual_oatmilk_formatting?key=0');
  page.waitFor('.activity-panel__add-poll');
  page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-types');
}

function openAdviceForm(page) {
  page.loadPath('setup_manual_oatmilk_advice_template');
  page.waitFor('.activity-panel__add-poll');
  page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-types');
  // The scenario installs Advice first, so the first visible proposal template
  // is deterministic even though persisted templates do not have key classes.
  page.clickAndWait('.decision-tools-card__poll-type', '.poll-common-form-fields__title input');
  page.fillIn('.poll-common-form-fields__title input', 'Choose a bottle washing supplier');
  page.fillIn(
    '.poll-common-form-fields__details textarea',
    'We need advice about capacity, food-safety records, water use, and support before selecting a supplier for the returnable bottle trial.'
  );
}

function markPollOptions(page, root = '.poll-common-form') {
  page.execute(`
    const root = document.querySelector('${root}');
    const heading = Array.from(root.querySelectorAll('.text-body-large'))
      .find(el => el.textContent.trim() === 'Options');
    heading.classList.add('manual-options-heading');
    heading.nextElementSibling.classList.add('manual-options-list');
  `);
  page.waitFor('.manual-options-list');
}

function openTemplateForm(page, custom = false) {
  page.loadPath(custom ? 'setup_manual_oatmilk_custom_poll_template?view=edit' : 'setup_manual_oatmilk_poll_template_form');
  page.waitFor('.poll-template-form');
}

function markTemplateField(page, label, className) {
  page.execute(`
    const field = Array.from(document.querySelectorAll('#poll-template-form .v-input'))
      .find(el => el.textContent.includes(${JSON.stringify(label)}));
    if (field) field.classList.add(${JSON.stringify(className)});
  `);
  page.waitFor(`.${className}`);
}

function captureTemplateSection(screenshot, name, selector, options = {}) {
  screenshot.captureElement(
    `polls/poll_templates/${name}`,
    selector,
    {width: 1100, height: 1800, ...options}
  );
}

function openCustomTemplateInChooser(page) {
  openTemplates(page, true);
  page.waitFor('.decision-tools-card__poll-type');
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'proposal_templates_list': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTemplates(page);
    captureTemplateSection(screenshot, 'proposal_templates_list', '.poll-common-templates-list', {height: 1400});
  },

  'proposal_advice_new': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openAdviceForm(page);
    screenshot.captureRegion(
      'polls/poll_templates/proposal_advice_new',
      ['.poll-common-form .v-card-title', '.poll-template-info-panel', '.poll-common-form-fields__title'],
      {width: 1100, height: 1600, padding: 16}
    );
  },

  'proposal_advice_new_details': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openAdviceForm(page);
    screenshot.captureRegion(
      'polls/poll_templates/proposal_advice_new_details',
      ['.poll-common-form-fields__title', '.poll-common-form-fields__details'],
      {width: 1100, height: 1700, padding: 16}
    );
  },

  'proposal_new_voting_options': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openAdviceForm(page);
    markPollOptions(page);
    screenshot.captureRegion(
      'polls/poll_templates/proposal_new_voting_options',
      ['.manual-options-heading', '.manual-options-list'],
      {width: 1100, height: 1600, padding: 16}
    );
  },

  'proposal_advice_new_closing': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openAdviceForm(page);
    captureTemplateSection(screenshot, 'proposal_advice_new_closing', '.poll-common-closing-at-field', {height: 1000});
  },

  'proposal_advice_new_advanced': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openAdviceForm(page);
    page.clickAndWait('.poll-common-form__more-settings', '.poll-common-form .v-expansion-panel-text');
    captureTemplateSection(screenshot, 'proposal_advice_new_advanced', '.poll-common-form .v-expansion-panel', {height: 2200});
  },

  'proposal_advice_new_voting': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_advice_poll');
    page.waitFor('.poll-common-vote-form');
    page.execute("Array.from(document.querySelectorAll('.poll-common-vote-form__button')).find(el => el.textContent.includes('Agree')).querySelector('label').click()");
    page.fillIn(
      '.poll-common-vote-form__reason [contenteditable=true]',
      'Confirm service response times and batch-record support before signing the supplier agreement.'
    );
    screenshot.captureRegion(
      'polls/poll_templates/proposal_advice_new_voting',
      ['.poll-common-action-panel h3', '.poll-common-vote-form', '.poll-common-form-actions'],
      {width: 1100, height: 2200, padding: 16}
    );
  },

  'proposal_advice_new_results': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_advice_poll?mode=results');
    page.waitFor('.poll-common-chart-panel');
    screenshot.captureRegion(
      'polls/poll_templates/proposal_advice_new_results',
      ['.poll-common-card__title', '.poll-common-chart-panel'],
      {width: 1100, height: 2000, padding: 16}
    );
  },

  'proposal_template_setting': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTemplates(page);
    captureTemplateSection(screenshot, 'proposal_template_setting', '.poll-common-templates-list', {
      height: 1200,
      spotlight: 'a[href*="/poll_templates/browse"]'
    });
  },

  'poll_template_new': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTemplateForm(page);
    screenshot.captureElement('polls/poll_templates/poll_template_new', '.poll-template-form', {width: 1100, height: 2400});
  },

  'poll_type_voting_method': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTemplateForm(page);
    page.click('#poll-template-form .v-select .v-field__input');
    page.waitFor('.v-overlay--active .v-list');
    screenshot.captureRegion(
      'polls/poll_templates/poll_type_voting_method',
      ['#poll-template-form .v-select', '.v-overlay--active .v-list'],
      {width: 1100, height: 1400, padding: 16}
    );
  },

  'template_WAAP_intro': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTemplateForm(page, true);
    markTemplateField(page, 'Template title', 'manual-template-title');
    markTemplateField(page, 'Template subtitle', 'manual-template-subtitle');
    markTemplateField(page, 'Template help', 'manual-template-help');
    screenshot.captureRegion(
      'polls/poll_templates/template_WAAP_intro',
      ['.manual-template-title', '.manual-template-subtitle', '.manual-template-help'],
      {width: 1100, height: 1800, padding: 16}
    );
  },

  'template_WAAP_details': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTemplateForm(page, true);
    markTemplateField(page, 'Example title', 'manual-example-title');
    markTemplateField(page, 'Details', 'manual-example-details');
    screenshot.captureRegion(
      'polls/poll_templates/template_WAAP_details',
      ['.manual-example-title', '.manual-example-details'],
      {width: 1100, height: 1800, padding: 16}
    );
  },

  'poll_type_edit_option': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTemplateForm(page, true);
    markPollOptions(page, '#poll-template-form');
    page.clickAndWait('.manual-options-list button[title="Edit"]', '.poll-common-option-form');
    captureTemplateSection(screenshot, 'poll_type_edit_option', '.poll-common-option-form', {height: 1400});
  },

  'poll_type_duration': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTemplateForm(page, true);
    markTemplateField(page, 'Default duration in days', 'manual-template-duration');
    captureTemplateSection(screenshot, 'poll_type_duration', '.manual-template-duration', {height: 900});
  },

  'template_WAAP_list': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openCustomTemplateInChooser(page);
    captureTemplateSection(screenshot, 'template_WAAP_list', '.poll-common-templates-list', {height: 1600});
  },

  'template_WAAP_start': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openCustomTemplateInChooser(page);
    page.clickAndWait('.decision-tools-card__poll-type', '.poll-common-form');
    screenshot.captureRegion(
      'polls/poll_templates/template_WAAP_start',
      ['.poll-template-info-panel', '.poll-common-form-fields__title', '.poll-common-form-fields__details'],
      {width: 1100, height: 2000, padding: 16}
    );
  },

  'template_manage': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openCustomTemplateInChooser(page);
    page.clickAndWait('.decision-tools-card__poll-type .action-menu--btn', '.v-overlay--active .v-list');
    screenshot.captureRegion(
      'polls/poll_templates/template_manage',
      ['.poll-common-templates-list', '.v-overlay--active .v-list'],
      {width: 1100, height: 1800, padding: 16}
    );
  },

  'template_manage_settings': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_custom_poll_template?hidden=1');
    page.waitFor('.activity-panel__add-poll');
    page.clickAndWait('.activity-panel__add-poll', '.poll-common-templates-list');
    page.clickAndWait('.poll-common-templates-list .d-flex.justify-center.my-2 .v-btn', '.poll-common-templates-list .v-list-subheader');
    captureTemplateSection(screenshot, 'template_manage_settings', '.poll-common-templates-list', {height: 1800});
  }
};
