import { test, expect } from '../fixtures.mjs';

test('successfully_updates_a_profile', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.goto('/profile')
  await expect(page.locator('.profile-page__name-input input')).toBeVisible()

  await page.locator('.profile-page__name-input input').fill('Ferris Bueller')
  await page.locator('.profile-page__username-input input').fill('ferris_bueller-jr')
  await page.locator('.profile-page .e2e-wysiwyg-btn').click()
  await page.locator('.profile-page .lmo-textarea div[contenteditable=true]').fill('Save Ferris')
  await page.locator('.profile-page__update-button').click()
  await expect(page.locator('.flash-root__message')).toContainText('Profile updated')

  await page.goto('/u/ferris_bueller-jr')
  await expect(page.locator('.user-page__content')).toContainText('Ferris Bueller')
  await expect(page.locator('.user-page__content')).toContainText('Save Ferris')
});

test('displays_a_user_and_their_non-secret_groups', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.goto('/u/jennifergrey')
  await expect(page.locator('.user-page__content')).toContainText('Jennifer Grey')
  await expect(page.locator('.user-page__content')).toContainText('@jennifergrey')
  await expect(page.locator('.user-page__activity')).toContainText('What star sign are you?')
  await expect(page.locator('.user-page__activity')).not.toContainText('Jennifer Grey')
  await expect(page.locator('.user-page__groups')).toContainText('Dirty Dancing Shoes')
});

test('displays_secret_groups_to_other_members', async ({ page }) => {
  await page.goto('/dev/setup_profile_with_group_visible_to_members')
  await expect(page.locator('.user-page__groups')).toContainText('Secret Dirty Dancing Shoes')
});

test('does_not_display_secret_groups_to_visitors', async ({ page }) => {
  await page.goto('/dev/setup_restricted_profile')
  await expect(page.locator('.user-page__groups')).not.toContainText('Secret Dirty Dancing Shoes')
});

test('does_not_accept_short_passwords', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.locator('.navbar__sidenav-toggle').click()
  await page.locator('.sidebar__user-dropdown').click()
  await page.locator('.user-dropdown__list-item-button--profile').click()
  await page.locator('.user-page__change_password').click()
  await page.locator('.change-password-form__password input').fill('Smush')
  await page.locator('.change-password-form__password-confirmation input').fill('Smush')
  await page.locator('.change-password-form__submit').click()
  await expect(page.locator('.change-password-form__password-container .lmo-validation-error__message')).toContainText("is too short")
});

test('does_not_accept_mismatched_passwords', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.locator('.navbar__sidenav-toggle').click()
  await page.locator('.sidebar__user-dropdown').click()
  await page.locator('.user-dropdown__list-item-button--profile').click()
  await page.locator('.user-page__change_password').click()
  await page.locator('.change-password-form__password input').fill('SmushDemBerries')
  await page.locator('.change-password-form__password-confirmation input').fill('SmishDemBorries')
  await page.locator('.change-password-form__submit').click()
  await expect(page.locator('.change-password-form__password-confirmation-container .lmo-validation-error__message')).toContainText("doesn't match")
});

test('can_set_a_password', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.locator('.navbar__sidenav-toggle').click()
  await page.locator('.sidebar__user-dropdown').click()
  await page.locator('.user-dropdown__list-item-button--profile').click()
  await page.locator('.user-page__change_password').click()
  await page.locator('.change-password-form__password input').fill('SmushDemBerries')
  await page.locator('.change-password-form__password-confirmation input').fill('SmushDemBerries')
  await page.locator('.change-password-form__submit').click()
  await expect(page.locator('.flash-root__message')).toContainText('Your password has been updated')
});

test('successfully_deactivates_the_account', async ({ page }) => {
  await page.goto('/dev/setup_group_with_multiple_coordinators')
  await page.locator('.navbar__sidenav-toggle').click()

  await page.locator('.sidebar__user-dropdown').click()
  await page.locator('.user-dropdown__list-item-button--profile').click()
  await page.locator('.user-page__redact_user').click()
  await page.locator('.confirm-modal__submit').click()
  await page.goto('/dashboard')
  await expect(page.locator('.auth-modal')).toContainText('Sign in to Loomio', { timeout: 20000 })
});

test('confirms_merge_accounts_from_email', async ({ page }) => {
  await page.goto('/dev/setup_merge_verification_email')
  await page.goto('/dev/last_email')
  await page.locator('.email-button').click()
  await page.locator('.btn--accent--raised').click()
  await expect(page.locator('.header')).toContainText('Merge successful!')
});

test('signs_out_after_sending_merge_verification', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.goto('/profile')
  await page.locator('.user-page__merge_accounts').click()
  await expect(page.locator('.merge-accounts-modal')).toBeVisible()
  await page.locator('.merge-accounts-modal__destination-email input').pressSequentially('jennifer@example.com')
  await page.locator('.merge-accounts-modal__submit').click()

  // Sending the verification email signs the source account out.
  await page.goto('/dashboard')
  await expect(page.locator('.auth-modal')).toContainText('Sign in to Loomio', { timeout: 20000 })
});

