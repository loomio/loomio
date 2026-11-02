import { test, expect } from '../fixtures.mjs';

test('successfully_updates_a_profile', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.goto('/profile')
  await expect(page.locator('.profile-page__name-input input')).toBeVisible()

  await page.fill('.profile-page__name-input input', 'Ferris Bueller')
  await page.fill('.profile-page__username-input input', 'ferris_bueller-jr')
  await page.click('.profile-page .e2e-wysiwyg-btn')
  await page.fill('.profile-page .lmo-textarea div[contenteditable=true]', 'Save Ferris')
  await page.click('.profile-page__update-button')
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
  await page.click('.navbar__sidenav-toggle')
  await page.click('.sidebar__user-dropdown')
  await page.click('.user-dropdown__list-item-button--profile')
  await page.click('.user-page__change_password')
  await page.fill('.change-password-form__password input', 'Smush')
  await page.fill('.change-password-form__password-confirmation input', 'Smush')
  await page.click('.change-password-form__submit')
  await expect(page.locator('.change-password-form__password-container .lmo-validation-error__message')).toContainText("is too short")
});

test('does_not_accept_mismatched_passwords', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.click('.navbar__sidenav-toggle')
  await page.click('.sidebar__user-dropdown')
  await page.click('.user-dropdown__list-item-button--profile')
  await page.click('.user-page__change_password')
  await page.fill('.change-password-form__password input', 'SmushDemBerries')
  await page.fill('.change-password-form__password-confirmation input', 'SmishDemBorries')
  await page.click('.change-password-form__submit')
  await expect(page.locator('.change-password-form__password-confirmation-container .lmo-validation-error__message')).toContainText("doesn't match")
});

test('can_set_a_password', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.click('.navbar__sidenav-toggle')
  await page.click('.sidebar__user-dropdown')
  await page.click('.user-dropdown__list-item-button--profile')
  await page.click('.user-page__change_password')
  await page.fill('.change-password-form__password input', 'SmushDemBerries')
  await page.fill('.change-password-form__password-confirmation input', 'SmushDemBerries')
  await page.click('.change-password-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Your password has been updated')
});

test('successfully_deactivates_the_account', async ({ page }) => {
  await page.goto('/dev/setup_group_with_multiple_coordinators')
  await page.click('.navbar__sidenav-toggle')

  await page.click('.sidebar__user-dropdown')
  await page.click('.user-dropdown__list-item-button--profile')
  await page.click('.user-page__redact_user')
  await page.click('.confirm-modal__submit')
  await page.goto('/dashboard')
  await expect(page.locator('.auth-modal')).toContainText('Sign in to Loomio', { timeout: 20000 })
});

test('confirms_merge_accounts_from_email', async ({ page }) => {
  await page.goto('/dev/setup_merge_verification_email')
  await page.goto('/dev/last_email')
  await page.click('.email-button')
  await page.click('.btn--accent--raised')
  await expect(page.locator('.header')).toContainText('Merge successful!')
});

test('signs_out_after_sending_merge_verification', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.goto('/profile')
  await page.click('.user-page__merge_accounts')
  await expect(page.locator('.merge-accounts-modal')).toBeVisible()
  await page.locator('.merge-accounts-modal__destination-email input').pressSequentially('jennifer@example.com')
  await page.click('.merge-accounts-modal__submit')

  // Sending the verification email signs the source account out.
  await page.goto('/dashboard')
  await expect(page.locator('.auth-modal')).toContainText('Sign in to Loomio', { timeout: 20000 })
});

