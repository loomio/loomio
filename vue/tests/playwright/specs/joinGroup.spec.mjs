import { test, expect } from '../fixtures.mjs';

test('hides_private_content', async ({ page }) => {
  await page.goto('/dev/setup_closed_group_to_join')
  await expect(page.locator('.group-page-actions button')).toHaveCount(0)
  await expect(page.locator('.discussions-panel__new-topic-button')).toHaveCount(0)
  await page.locator('.group-page-members-tab').click()
  await expect(page.locator('.members-panel')).toContainText('You do not have permission to do this.')
});

test('displays_public_content', async ({ page }) => {
  await page.goto('/dev/setup_closed_group_to_join')
  await expect(page.locator('.group-page__description')).toContainText('An FBI agent goes undercover')
  await expect(page.locator('.topic-previews')).toContainText("The name's Johnny Utah!")
});

test('adds_you_to_the_group_when_button_is_clicked', async ({ page }) => {
  await page.goto('/dev/setup_public_group_to_join_upon_request')
  await page.locator('.join-group-button').click()
  await expect(page.locator('.flash-root__message')).toContainText('You are now a member of')
  await page.locator('.group-page-members-tab').click()

  await expect(page.locator('.members-panel')).toContainText('Jennifer')
});

test('requests_membership_when_button_is_clicked', async ({ page }) => {
  await page.goto('/dev/setup_closed_group_to_join')
  await page.locator('.join-group-button').click()
  await page.locator('.membership-request-form__introduction textarea').fill('Hello I am a bot and id like to advertise junk to your fine membership')
  await page.locator('.membership-request-form__submit-btn').click()
  await expect(page.locator('.flash-root__message')).toContainText('You have requested to join')
  await expect(page.locator('.join-group-button')).toContainText('Membership requested')
  await expect(page.locator('.join-group-button').first()).toBeDisabled()
});

test('shows_decline_reason_and_allows_another_request', async ({ page }) => {
  await page.goto('/dev/setup_manual_oatmilk_declined_membership_request')
  await expect(page.locator('.group-page')).toContainText('Your request to join was declined: Please tell us which cafe you work with and how you would like to contribute.')
  await expect(page.locator('.join-group-button')).toContainText('Ask to join again')
  await page.locator('.join-group-button').click()
  await page.locator('.membership-request-form__introduction textarea').fill('I work with Harbour Cafe and can help coordinate Tuesday bottle collections.')
  await page.locator('.membership-request-form__submit-btn').click()
  await expect(page.locator('.flash-root__message')).toContainText('You have requested to join')
  await expect(page.locator('.join-group-button')).toContainText('Membership requested')
});

test('does_not_allow_another_request_after_ignore', async ({ page }) => {
  await page.goto('/dev/setup_manual_oatmilk_ignored_membership_request')
  await expect(page.locator('.join-group-button')).toHaveCount(0)
  await expect(page.locator('.group-page')).not.toContainText('Your request to join was declined')
});

test('can_join_closed_subgroup_when_admin_of_parent_group', async ({ page }) => {
  await page.goto('/dev/setup_group_with_subgroups_as_admin_landing_in_other_subgroup')
  await page.locator('.join-group-button').click()
  await expect(page.locator('.flash-root__message')).toContainText('You are now a member of Point Break - Bodhi')
});
