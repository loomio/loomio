import { test, expect } from '../fixtures.mjs';

test('browse_page_displays_templates', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion_template_browse')
  await page.expectText('.discussion-templates-browse-page', 'Advice process')
  await page.expectText('.discussion-templates-browse-page', 'Consent process')
});

test('nonmember_can_submit_a_nomination_from_a_group_template', async ({ lmo: page }) => {
  await page.loadPath('setup_nonmember_nomination')
  await page.expectText('.group-page__name', 'Dirty Dancing Shoes')
  await page.expectNoElement('.join-group-button')
  await page.click('.discussions-panel__new-topic-button')
  await page.expectText('.discussion-templates-page', 'Nominate a candidate')
  await page.click('.discussion-templates--template')
  await page.expectText('.discussion-form', 'Who are you nominating, and for which position?')
  await page.expectNoElement('.common-notify-fields')
  await page.expectNoElement('.flash-root__message')
  await page.fillIn('.discussion-form__title-input input', 'Sam Rivera — Board chair')
  await page.click('.discussion-form__submit')
  await page.expectFlash('Discussion started')
  await page.expectText('.context-panel__heading', 'Sam Rivera — Board chair')
  await page.expectText('.context-panel__description', 'Why is this person suitable?')
  await page.expectNoElement('.action-dock__button--announce_thread')
});

test('member_loading_a_template_form_directly_can_notify_the_group', async ({ lmo: page }) => {
  await page.loadPath('setup_member_nomination_form')
  await page.expectText('.discussion-form', 'Who are you nominating, and for which position?')
  await page.expectElement('.discussion-form .tags-field__input')
  await page.expectText('.discussion-form .common-notify-fields', 'Dirty Dancing Shoes')
});

test('nonmember_loading_a_template_form_directly_cannot_notify_the_group', async ({ lmo: page }) => {
  await page.loadPath('setup_nonmember_nomination_form')
  await page.expectText('.discussion-form', 'Who are you nominating, and for which position?')
  await page.pause(2000)
  await page.expectNoElement('.discussion-form .tags-field__input')
  await page.expectNoElement('.common-notify-fields')
});
