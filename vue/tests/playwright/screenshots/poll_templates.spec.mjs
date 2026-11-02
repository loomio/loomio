import { test, expect } from '../screenshotFixtures.mjs';

async function openTemplates(page, custom = false) {
  await page.loadPath(custom ? 'setup_manual_oatmilk_custom_poll_template' : 'setup_manual_oatmilk_formatting?key=0');
  await page.waitFor('.activity-panel__add-poll');
  await page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-types');
}

async function openAdviceForm(page) {
  await page.loadPath('setup_manual_oatmilk_advice_template');
  await page.waitFor('.activity-panel__add-poll');
  await page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-types');
  // The scenario installs Advice first, so the first visible proposal template
  // is deterministic even though persisted templates do not have key classes.
  await page.clickAndWait('.decision-tools-card__poll-type', '.poll-common-form-fields__title input');
  await page.fillIn('.poll-common-form-fields__title input', 'Choose a bottle washing supplier');
  await page.fillTextarea(
    '.poll-common-form-fields__details textarea',
    'We need advice about **capacity, food-safety records, and water use** before selecting a washing supplier. 🧼\n\nCompare response times, batch-record support, and the practical limits of each service.\n\nRead the [supplier questions](https://example.com/oatmilk-supplier-questions) and add anything we should ask before signing an agreement.'
  );
}

async function markPollOptions(page, root = '.poll-common-form') {
  await page.execute(`
    const root = document.querySelector('${root}');
    const heading = root.querySelector('.poll-common-form__options-heading');
    heading.classList.add('manual-options-heading');
    heading.nextElementSibling.classList.add('manual-options-list');
  `);
  await page.waitFor('.manual-options-list');
}

async function openTemplateForm(page, custom = false) {
  await page.loadPath(custom ? 'setup_manual_oatmilk_custom_poll_template?view=edit' : 'setup_manual_oatmilk_poll_template_form');
  await page.waitFor('.poll-template-form');
  await page.waitFor('.poll-template-form-fields__title input');
  await page.waitFor('.poll-template-form-fields__title-placeholder input');
  await page.waitFor('.poll-template-form__submit');
}

async function markTemplateField(page, fieldClass, className) {
  await page.execute(`
    const field = document.querySelector(${JSON.stringify(`#poll-template-form .${fieldClass}`)});
    if (field) field.classList.add(${JSON.stringify(className)});
  `);
  await page.waitFor(`.${className}`);
}

async function captureTemplateSection(screenshot, name, selector, options = {}) {
  await screenshot.captureElement(
    `polls/poll_templates/${name}`,
    selector,
    {width: 1100, height: 1800, ...options}
  );
}

async function openCustomTemplateInChooser(page) {
  await openTemplates(page, true);
  await page.waitFor('.decision-tools-card__poll-type');
}

test('save_as_template', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_consent_process');
  await page.expectText('.poll-created', 'Require two approvals for payments over $2,000');
  await page.expectText('.poll-created', 'We will review the policy after three months');
  await page.expectText('.poll-created .tags-display', 'Policy');
  await page.resizeWindow(800, 1800);
  await page.pause(500);
  await page.execute('window.scrollTo(0, 0)');
  await page.clickAndWait('.poll-created .action-menu--btn', '.v-overlay--active .action-dock__button--save_as_template');
  await page.expectText('.v-overlay--active .action-dock__button--save_as_template', 'Save as template');
  await screenshot.captureRegion(
    'polls/poll_templates/save_as_template',
    ['section.poll-created .topic-header', 'section.poll-created .action-dock', '.v-overlay--active .v-list'],
    {
      width: 800,
      height: 1800,
      padding: 32,
      spotlight: {selectors: ['.poll-created .action-menu--btn', '.v-overlay--active .v-list'], padding: 12, radius: 16, opacity: 0.4, outlineWidth: 0}
    }
  );
});

test('proposal_templates_list', async ({ lmo: page, manual: screenshot }) => {
  await openTemplates(page);
  await captureTemplateSection(screenshot, 'proposal_templates_list', '.poll-common-templates-list', {height: 1400});
});

test('proposal_advice_new', async ({ lmo: page, manual: screenshot }) => {
  await openAdviceForm(page);
  await screenshot.captureRegion(
    'polls/poll_templates/proposal_advice_new',
    ['.poll-common-form .v-card-title', '.poll-template-info-panel', '.poll-common-form-fields__title'],
    {width: 1100, height: 1600, padding: 16}
  );
});

test('proposal_advice_new_details', async ({ lmo: page, manual: screenshot }) => {
  await openAdviceForm(page);
  await screenshot.captureRegion(
    'polls/poll_templates/proposal_advice_new_details',
    ['.poll-common-form-fields__title', '.poll-common-form-fields__details'],
    {width: 1100, height: 1700, padding: 16}
  );
});

test('proposal_new_voting_options', async ({ lmo: page, manual: screenshot }) => {
  await openAdviceForm(page);
  await markPollOptions(page);
  await screenshot.captureRegion(
    'polls/poll_templates/proposal_new_voting_options',
    ['.manual-options-heading', '.manual-options-list'],
    {width: 1100, height: 1600, padding: 16}
  );
});

test('proposal_advice_new_closing', async ({ lmo: page, manual: screenshot }) => {
  await openAdviceForm(page);
  await captureTemplateSection(screenshot, 'proposal_advice_new_closing', '.poll-common-closing-at-field', {height: 1000});
});

test('proposal_advice_new_advanced', async ({ lmo: page, manual: screenshot }) => {
  await openAdviceForm(page);
  await page.clickAndWait('.poll-common-form__more-settings', '.poll-common-form .v-expansion-panel-text');
  await captureTemplateSection(screenshot, 'proposal_advice_new_advanced', '.poll-common-form .v-expansion-panel', {height: 2200});
});

test('proposal_advice_new_voting', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_advice_poll');
  await page.waitFor('.poll-common-vote-form');
  await page.execute("document.querySelector('.poll-common-vote-form__button--agree label').click()");
  await page.fillIn(
    '.poll-common-vote-form__reason [contenteditable=true]',
    'Confirm service response times and batch-record support before signing the supplier agreement.'
  );
  await screenshot.captureRegion(
    'polls/poll_templates/proposal_advice_new_voting',
    ['.poll-common-action-panel h3', '.poll-common-vote-form', '.poll-common-form-actions'],
    {width: 1100, height: 2200, padding: 16}
  );
});

test('proposal_advice_new_results', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_advice_poll?mode=results');
  await page.waitFor('.poll-common-chart-panel');
  await screenshot.captureRegion(
    'polls/poll_templates/proposal_advice_new_results',
    ['.poll-common-card__title', '.poll-common-chart-panel'],
    {width: 1100, height: 2000, padding: 16}
  );
});

test('proposal_template_setting', async ({ lmo: page, manual: screenshot }) => {
  await openTemplates(page);
  await captureTemplateSection(screenshot, 'proposal_template_setting', '.poll-common-templates-list', {
    height: 1200,
    spotlight: 'a[href*="/poll_templates/browse"]'
  });
});

test('poll_template_new', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_custom_poll_template?view=new');
  await page.waitFor('.poll-template-form__help');
  await page.expectElement('.poll-template-form-fields__details [contenteditable=true]');
  await page.fillIn('.poll-template-form-fields__process-name input', 'Policy change consent process');
  await page.expectValue('.poll-template-form-fields__process-subtitle input', 'Reach consent on changes to group policies');
  await page.expectText('.poll-template-form .tags-field__input', 'Policy');
  await page.expectText('.poll-template-form', 'Consent with concerns');
  await screenshot.captureRegion('polls/poll_templates/poll_template_new', ['.poll-template-form'], {
    width: 1100,
    height: 6400,
    padding: 32,
    scrollSelector: '.poll-template-form',
    scrollBlock: 'start',
    clearSelection: true
  });
});

test('poll_type_voting_method', async ({ lmo: page, manual: screenshot }) => {
  await openTemplateForm(page);
  await page.click('#poll-template-form .v-select .v-field__input');
  await page.waitFor('.v-overlay--active .v-list');
  await screenshot.captureRegion(
    'polls/poll_templates/poll_type_voting_method',
    ['#poll-template-form .v-select', '.v-overlay--active .v-list'],
    {width: 1100, height: 1400, padding: 16}
  );
});

test('template_WAAP_intro', async ({ lmo: page, manual: screenshot }) => {
  await openTemplateForm(page, true);
  await page.expectElement('.poll-template-form-fields__process-introduction [contenteditable=true]');
  await page.expectText('.poll-template-form-fields__process-introduction', 'Use this process when a proposed change affects group policies');
  await markTemplateField(page, 'poll-template-form-fields__process-name', 'manual-template-title');
  await markTemplateField(page, 'poll-template-form-fields__process-subtitle', 'manual-template-subtitle');
  await markTemplateField(page, 'poll-template-form-fields__process-introduction', 'manual-template-help');
  await screenshot.captureRegion(
    'polls/poll_templates/template_WAAP_intro',
    ['.manual-template-title', '.manual-template-subtitle', '.manual-template-help'],
    {width: 1100, height: 1800, padding: 16}
  );
});

test('template_WAAP_details', async ({ lmo: page, manual: screenshot }) => {
  await openTemplateForm(page, true);
  await page.expectElement('.poll-template-form-fields__details [contenteditable=true]');
  await page.expectText('.poll-template-form-fields__details', 'Proposed policy change');
  await markTemplateField(page, 'poll-template-form-fields__title-placeholder', 'manual-example-title');
  await markTemplateField(page, 'poll-template-form-fields__details', 'manual-example-details');
  await screenshot.captureRegion(
    'polls/poll_templates/template_WAAP_details',
    ['.manual-example-title', '.manual-example-details'],
    {width: 1100, height: 1800, padding: 16}
  );
});

test('poll_type_edit_option', async ({ lmo: page, manual: screenshot }) => {
  await openTemplateForm(page, true);
  await markPollOptions(page, '#poll-template-form');
  await page.clickAndWait('.manual-options-list .poll-common-form__edit-option', '.poll-common-option-form');
  await captureTemplateSection(screenshot, 'poll_type_edit_option', '.poll-common-option-form', {height: 1400});
});

test('poll_type_duration', async ({ lmo: page, manual: screenshot }) => {
  await openTemplateForm(page, true);
  await markTemplateField(page, 'poll-template-form-fields__duration', 'manual-template-duration');
  await captureTemplateSection(screenshot, 'poll_type_duration', '.manual-template-duration', {height: 900});
});

test('template_WAAP_list', async ({ lmo: page, manual: screenshot }) => {
  await openCustomTemplateInChooser(page);
  await captureTemplateSection(screenshot, 'template_WAAP_list', '.poll-common-templates-list', {height: 1600});
});

test('template_WAAP_start', async ({ lmo: page, manual: screenshot }) => {
  await openCustomTemplateInChooser(page);
  await page.clickAndWait('.decision-tools-card__poll-type', '.poll-common-form');
  await screenshot.captureRegion(
    'polls/poll_templates/template_WAAP_start',
    ['.poll-template-info-panel', '.poll-common-form-fields__title', '.poll-common-form-fields__details'],
    {width: 1100, height: 2000, padding: 16}
  );
});

test('edit_default_template', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_custom_poll_template?view=list');
  await page.expectText('.poll-common-templates-list', 'Policy change consent process');
  await page.resizeWindow(1100, 1300);
  await page.pause(300);
  await page.execute(`document.querySelector('.poll-common-templates-list').closest('.v-card').classList.add('manual-template-list-card')`);
  await page.clickAndWait('.decision-tools-card__template--consent .action-menu--btn', '.v-overlay--active .action-dock__button--edit_default_template');
  await screenshot.captureRegion(
    'polls/poll_templates/edit_default_template',
    ['.poll-form-page .v-breadcrumbs a', '.manual-template-list-card', '.v-overlay--active .v-list'],
    {
      width: 1100,
      height: 1300,
      padding: 24,
      spotlight: {selectors: ['.decision-tools-card__template--consent .action-menu--btn', '.v-overlay--active .v-list'], padding: 12, radius: 16, opacity: 0.4, outlineWidth: 0}
    }
  );
  await page.clickAndWait('.action-dock__button--edit_default_template', '.poll-template-form');
  await page.expectValue('.poll-template-form-fields__process-name input', '');
  await page.expectText('.poll-template-form', 'Consent');
});

test('template_manage', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_custom_poll_template?view=list');
  await page.expectText('.poll-common-templates-list', 'Policy change consent process');
  await page.resizeWindow(1100, 1300);
  await page.pause(300);
  await page.execute(`document.querySelector('.poll-common-templates-list').closest('.v-card').classList.add('manual-template-list-card')`);
  await page.clickAndWait('.decision-tools-card__poll-type .action-menu--btn', '.v-overlay--active .v-list');
  await screenshot.captureRegion(
    'polls/poll_templates/template_manage',
    ['.poll-form-page .v-breadcrumbs a', '.manual-template-list-card', '.v-overlay--active .v-list'],
    {
      width: 1100,
      height: 1300,
      padding: 24,
      spotlight: {selectors: ['.decision-tools-card__poll-type .action-menu--btn', '.v-overlay--active .v-list'], padding: 12, radius: 16, opacity: 0.4, outlineWidth: 0}
    }
  );
});

test('template_manage_settings', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_custom_poll_template?hidden=1');
  await page.waitFor('.activity-panel__add-poll');
  await page.clickAndWait('.activity-panel__add-poll', '.poll-common-templates-list');
  await page.clickAndWait('.poll-common-templates-list .d-flex.justify-center.my-2 .v-btn', '.poll-common-templates-list .v-list-subheader');
  await captureTemplateSection(screenshot, 'template_manage_settings', '.poll-common-templates-list', {height: 1800});
});
