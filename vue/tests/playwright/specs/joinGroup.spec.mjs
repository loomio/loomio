import { test, expect } from '../fixtures.mjs';

// GK: dislaying discussions from open groups
// GK: displaying public discussions?

test('hides_private_content', async ({ lmo: page }) => {
  await page.loadPath('setup_closed_group_to_join')
  await page.expectNoElement('.group-page-actions button')
  await page.expectNoElement('.discussions-panel__new-topic-button')
  await page.click('.group-page-members-tab')
  await page.expectText('.members-panel', 'You do not have permission to do this.')
});

test('displays_public_content', async ({ lmo: page }) => {
  await page.loadPath('setup_closed_group_to_join')
  await page.expectText('.group-page__description', 'An FBI agent goes undercover')
  await page.expectText('.topic-previews', "The name's Johnny Utah!")
  // page.ensureSidebar()
  // page.expectText('.sidebar__groups', 'Johnny Utah')
});

test('adds_you_to_the_group_when_button_is_clicked', async ({ lmo: page }) => {
  await page.loadPath('setup_public_group_to_join_upon_request')
  await page.click('.join-group-button')
  await page.expectFlash('You are now a member of')
  await page.click('.group-page-members-tab')

  await page.expectText('.members-panel', 'Jennifer')
});

test('requests_membership_when_button_is_clicked', async ({ lmo: page }) => {
  await page.loadPath('setup_closed_group_to_join')
  await page.click('.join-group-button')
  await page.fillIn('.membership-request-form__introduction textarea', 'Hello I am a bot and id like to advertise junk to your fine membership')
  await page.click('.membership-request-form__submit-btn')
  await page.expectFlash('You have requested to join')
  await page.expectText('.join-group-button', 'Membership requested')
  await expect(page.first('.join-group-button')).toBeDisabled()
});

test('shows_decline_reason_and_allows_another_request', async ({ lmo: page }) => {
  await page.loadPath('setup_manual_oatmilk_declined_membership_request')
  await page.expectText('.group-page', 'Your request to join was declined: Please tell us which cafe you work with and how you would like to contribute.')
  await page.expectText('.join-group-button', 'Ask to join again')
  await page.click('.join-group-button')
  await page.fillIn('.membership-request-form__introduction textarea', 'I work with Harbour Cafe and can help coordinate Tuesday bottle collections.')
  await page.click('.membership-request-form__submit-btn')
  await page.expectFlash('You have requested to join')
  await page.expectText('.join-group-button', 'Membership requested')
});

test('does_not_allow_another_request_after_ignore', async ({ lmo: page }) => {
  await page.loadPath('setup_manual_oatmilk_ignored_membership_request')
  await page.expectNoElement('.join-group-button')
  await page.expectNoText('.group-page', 'Your request to join was declined')
});

test('can_join_closed_subgroup_when_admin_of_parent_group', async ({ lmo: page }) => {
  await page.loadPath('setup_group_with_subgroups_as_admin_landing_in_other_subgroup')
  await page.click('.join-group-button')
  await page.expectFlash('You are now a member of Point Break - Bodhi')
});
