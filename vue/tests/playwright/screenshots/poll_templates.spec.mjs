import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

async function openTemplates(page, custom = false) {
  await page.goto(`/dev/${custom ? 'setup_manual_oatmilk_custom_poll_template' : 'setup_manual_oatmilk_formatting?key=0'}`)
  await page.locator('.activity-panel__add-poll').click()
}

async function openAdviceForm(page) {
  await page.goto('/dev/setup_manual_oatmilk_advice_template')
  await page.locator('.activity-panel__add-poll').click()
  // The scenario installs Advice first, so the first visible proposal template
  // is deterministic even though persisted templates do not have key classes.
  await page.locator('.decision-tools-card__poll-type').click()
  await page.locator('.poll-common-form-fields__title input').fill('Choose a bottle washing supplier')
  await page.locator('.poll-common-form-fields__details textarea').evaluate((textarea, value) => {
    Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype, 'value').set.call(textarea, value)
    textarea.dispatchEvent(new Event('input', { bubbles: true }))
  }, 'We need advice about **capacity, food-safety records, and water use** before selecting a washing supplier. 🧼\n\nCompare response times, batch-record support, and the practical limits of each service.\n\nRead the [supplier questions](https://example.com/oatmilk-supplier-questions) and add anything we should ask before signing an agreement.')
}

async function markPollOptions(page, root = '.poll-common-form') {
  await page.evaluate(`
    const root = document.querySelector('${root}');
    const heading = root.querySelector('.poll-common-form__options-heading');
    heading.classList.add('manual-options-heading');
    heading.nextElementSibling.classList.add('manual-options-list');
  `)
  await expect(page.locator('.manual-options-list').first()).toBeVisible()
}

async function openTemplateForm(page, custom = false) {
  await page.goto(`/dev/${custom ? 'setup_manual_oatmilk_custom_poll_template?view=edit' : 'setup_manual_oatmilk_poll_template_form'}`)
  await expect(page.locator('.poll-template-form').first()).toBeVisible()
  await expect(page.locator('.poll-template-form-fields__title input').first()).toBeVisible()
  await expect(page.locator('.poll-template-form-fields__title-placeholder input').first()).toBeVisible()
  await expect(page.locator('.poll-template-form__submit').first()).toBeVisible()
}

async function markTemplateField(page, fieldClass, className) {
  await page.evaluate(`
    const field = document.querySelector(${JSON.stringify(`#poll-template-form .${fieldClass}`)});
    if (field) field.classList.add(${JSON.stringify(className)});
  `)
  await expect(page.locator(`.${className}`).first()).toBeVisible()
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
  await expect(page.locator('.decision-tools-card__poll-type').first()).toBeVisible()
}

test('save_as_template', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_consent_process')
  await expectLabel(page.locator('.poll-created'), 'Require two approvals for payments over $2,000')
  await expectLabel(page.locator('.poll-created'), 'We will review the policy after three months')
  await expectLabel(page.locator('.poll-created .tags-display'), 'Policy')
  await page.setViewportSize({ width: 800, height: 1800 })
  await page.evaluate('window.scrollTo(0, 0)')
  await page.locator('.poll-created .action-menu--btn').click()
  await expectLabel(page.locator('.v-overlay--active .action-dock__button--save_as_template'), 'Save as template')
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

test('proposal_templates_list', async ({ page, manual: screenshot }) => {
  await openTemplates(page);
  await captureTemplateSection(screenshot, 'proposal_templates_list', '.poll-common-templates-list', {height: 1400});
});

test('proposal_advice_new', async ({ page, manual: screenshot }) => {
  await openAdviceForm(page);
  await screenshot.captureRegion(
    'polls/poll_templates/proposal_advice_new',
    ['.poll-common-form .v-card-title', '.poll-template-info-panel', '.poll-common-form-fields__title'],
    {width: 1100, height: 1600, padding: 16}
  );
});

test('proposal_advice_new_details', async ({ page, manual: screenshot }) => {
  await openAdviceForm(page);
  await screenshot.captureRegion(
    'polls/poll_templates/proposal_advice_new_details',
    ['.poll-common-form-fields__title', '.poll-common-form-fields__details'],
    {width: 1100, height: 1700, padding: 16}
  );
});

test('proposal_new_voting_options', async ({ page, manual: screenshot }) => {
  await openAdviceForm(page);
  await markPollOptions(page);
  await screenshot.captureRegion(
    'polls/poll_templates/proposal_new_voting_options',
    ['.manual-options-heading', '.manual-options-list'],
    {width: 1100, height: 1600, padding: 16}
  );
});

test('proposal_advice_new_closing', async ({ page, manual: screenshot }) => {
  await openAdviceForm(page);
  await captureTemplateSection(screenshot, 'proposal_advice_new_closing', '.poll-common-closing-at-field', {height: 1000});
});

test('proposal_advice_new_advanced', async ({ page, manual: screenshot }) => {
  await openAdviceForm(page);
  await page.locator('.poll-common-form__more-settings').click()
  await captureTemplateSection(screenshot, 'proposal_advice_new_advanced', '.poll-common-form .v-expansion-panel', {height: 2200});
});

test('proposal_advice_new_voting', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_advice_poll')
  await expect(page.locator('.poll-common-vote-form').first()).toBeVisible()
  await page.evaluate("document.querySelector('.poll-common-vote-form__button--agree label').click()")
  await page.locator('.poll-common-vote-form__reason [contenteditable=true]').fill('Confirm service response times and batch-record support before signing the supplier agreement.')
  await screenshot.captureRegion(
    'polls/poll_templates/proposal_advice_new_voting',
    ['.poll-common-action-panel h3', '.poll-common-vote-form', '.poll-common-form-actions'],
    {width: 1100, height: 2200, padding: 16}
  );
});

test('proposal_advice_new_results', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_advice_poll?mode=results')
  await expect(page.locator('.poll-common-chart-panel').first()).toBeVisible()
  await screenshot.captureRegion(
    'polls/poll_templates/proposal_advice_new_results',
    ['.poll-common-card__title', '.poll-common-chart-panel'],
    {width: 1100, height: 2000, padding: 16}
  );
});

test('proposal_template_setting', async ({ page, manual: screenshot }) => {
  await openTemplates(page);
  await captureTemplateSection(screenshot, 'proposal_template_setting', '.poll-common-templates-list', {
    height: 1200,
    spotlight: 'a[href*="/poll_templates/browse"]'
  });
});

test('poll_template_new', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_custom_poll_template?view=new')
  await expect(page.locator('.poll-template-form__help').first()).toBeVisible()
  await expect(page.locator('.poll-template-form-fields__details [contenteditable=true]').first()).toBeVisible()
  await page.locator('.poll-template-form-fields__process-name input').fill('Policy change consent process')
  await expect(page.locator('.poll-template-form-fields__process-subtitle input')).toHaveValue('Reach consent on changes to group policies')
  await expectLabel(page.locator('.poll-template-form .tags-field__input'), 'Policy')
  await expectLabel(page.locator('.poll-template-form'), 'Consent with concerns')
  await screenshot.captureRegion('polls/poll_templates/poll_template_new', ['.poll-template-form'], {
    width: 1100,
    height: 6400,
    padding: 32,
    scrollSelector: '.poll-template-form',
    scrollBlock: 'start',
    clearSelection: true
  });
});

test('poll_type_voting_method', async ({ page, manual: screenshot }) => {
  await openTemplateForm(page);
  await page.locator('#poll-template-form .v-select .v-field__input').click()
  await expect(page.locator('.v-overlay--active .v-list').first()).toBeVisible()
  await screenshot.captureRegion(
    'polls/poll_templates/poll_type_voting_method',
    ['#poll-template-form .v-select', '.v-overlay--active .v-list'],
    {width: 1100, height: 1400, padding: 16}
  );
});

test('template_WAAP_intro', async ({ page, manual: screenshot }) => {
  await openTemplateForm(page, true);
  await expect(page.locator('.poll-template-form-fields__process-introduction [contenteditable=true]').first()).toBeVisible()
  await expectLabel(page.locator('.poll-template-form-fields__process-introduction'), 'Use this process when a proposed change affects group policies')
  await markTemplateField(page, 'poll-template-form-fields__process-name', 'manual-template-title');
  await markTemplateField(page, 'poll-template-form-fields__process-subtitle', 'manual-template-subtitle');
  await markTemplateField(page, 'poll-template-form-fields__process-introduction', 'manual-template-help');
  await screenshot.captureRegion(
    'polls/poll_templates/template_WAAP_intro',
    ['.manual-template-title', '.manual-template-subtitle', '.manual-template-help'],
    {width: 1100, height: 1800, padding: 16}
  );
});

test('template_WAAP_details', async ({ page, manual: screenshot }) => {
  await openTemplateForm(page, true);
  await expect(page.locator('.poll-template-form-fields__details [contenteditable=true]').first()).toBeVisible()
  await expectLabel(page.locator('.poll-template-form-fields__details'), 'Proposed policy change')
  await markTemplateField(page, 'poll-template-form-fields__title-placeholder', 'manual-example-title');
  await markTemplateField(page, 'poll-template-form-fields__details', 'manual-example-details');
  await screenshot.captureRegion(
    'polls/poll_templates/template_WAAP_details',
    ['.manual-example-title', '.manual-example-details'],
    {width: 1100, height: 1800, padding: 16}
  );
});

test('poll_type_edit_option', async ({ page, manual: screenshot }) => {
  await openTemplateForm(page, true);
  await markPollOptions(page, '#poll-template-form');
  await page.locator('.manual-options-list .poll-common-form__edit-option').click()
  await captureTemplateSection(screenshot, 'poll_type_edit_option', '.poll-common-option-form', {height: 1400});
});

test('poll_type_duration', async ({ page, manual: screenshot }) => {
  await openTemplateForm(page, true);
  await markTemplateField(page, 'poll-template-form-fields__duration', 'manual-template-duration');
  await captureTemplateSection(screenshot, 'poll_type_duration', '.manual-template-duration', {height: 900});
});

test('template_WAAP_list', async ({ page, manual: screenshot }) => {
  await openCustomTemplateInChooser(page);
  await captureTemplateSection(screenshot, 'template_WAAP_list', '.poll-common-templates-list', {height: 1600});
});

test('template_WAAP_start', async ({ page, manual: screenshot }) => {
  await openCustomTemplateInChooser(page);
  await page.locator('.decision-tools-card__poll-type').click()
  await screenshot.captureRegion(
    'polls/poll_templates/template_WAAP_start',
    ['.poll-template-info-panel', '.poll-common-form-fields__title', '.poll-common-form-fields__details'],
    {width: 1100, height: 2000, padding: 16}
  );
});

test('edit_default_template', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_custom_poll_template?view=list')
  await expectLabel(page.locator('.poll-common-templates-list'), 'Policy change consent process')
  await page.setViewportSize({ width: 1100, height: 1300 })
  await page.evaluate(`document.querySelector('.poll-common-templates-list').closest('.v-card').classList.add('manual-template-list-card')`)
  await page.locator('.decision-tools-card__template--consent .action-menu--btn').click()
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
  await page.locator('.action-dock__button--edit_default_template').click()
  await expect(page.locator('.poll-template-form-fields__process-name input')).toHaveValue('')
  await expectLabel(page.locator('.poll-template-form'), 'Consent')
});

test('template_manage', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_custom_poll_template?view=list')
  await expectLabel(page.locator('.poll-common-templates-list'), 'Policy change consent process')
  await page.setViewportSize({ width: 1100, height: 1300 })
  await page.evaluate(`document.querySelector('.poll-common-templates-list').closest('.v-card').classList.add('manual-template-list-card')`)
  await page.locator('.decision-tools-card__poll-type .action-menu--btn').click()
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

test('template_manage_settings', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_custom_poll_template?hidden=1')
  await page.locator('.activity-panel__add-poll').click()
  await page.locator('.poll-common-templates-list .d-flex.justify-center.my-2 .v-btn').click()
  await captureTemplateSection(screenshot, 'template_manage_settings', '.poll-common-templates-list', {height: 1800});
});
