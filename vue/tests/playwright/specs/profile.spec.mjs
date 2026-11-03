import { test, expect } from '../fixtures.mjs';
import { editor } from '../helpers/editor.mjs';
import { openSidebar } from '../helpers/groups.mjs';

const userPage = page => page.locator('.user-page__content');
const groups = page => page.locator('.user-page__groups');
const signInModal = page => page.locator('.auth-modal');

async function openOwnProfile(page) {
  await openSidebar(page);
  await page.locator('.sidebar__user-dropdown').click();
  await page.locator('.user-dropdown__list-item-button--profile').click();
}

test('updates a profile', async ({ page, flash }) => {
  await page.goto('/dev/setup_discussion');
  await page.goto('/profile');
  const profile = page.locator('.profile-page');
  await profile.locator('.profile-page__name-input input').fill('Ferris Bueller');
  await profile.locator('.profile-page__username-input input').fill('ferris_bueller-jr');
  await profile.locator('.e2e-wysiwyg-btn').click();
  await editor(profile).fill('Save Ferris');
  await profile.locator('.profile-page__update-button').click();
  await expect(flash).toContainText('Profile updated');

  await page.goto('/u/ferris_bueller-jr');
  await expect(userPage(page)).toContainText('Ferris Bueller');
  await expect(userPage(page)).toContainText('Save Ferris');
});

test.describe('a user page', () => {
  test('shows the user, their activity and their non-secret groups', async ({ page }) => {
    await page.goto('/dev/setup_discussion');
    await page.goto('/u/jennifergrey');
    await expect(userPage(page)).toContainText('Jennifer Grey');
    await expect(userPage(page)).toContainText('@jennifergrey');
    await expect(page.locator('.user-page__activity')).toContainText('What star sign are you?');
    await expect(page.locator('.user-page__activity')).not.toContainText('Jennifer Grey');
    await expect(groups(page)).toContainText('Dirty Dancing Shoes');
  });

  test('shows secret groups to other members', async ({ page }) => {
    await page.goto('/dev/setup_profile_with_group_visible_to_members');
    await expect(groups(page)).toContainText('Secret Dirty Dancing Shoes');
  });

  test('hides secret groups from visitors', async ({ page }) => {
    await page.goto('/dev/setup_restricted_profile');
    await expect(userPage(page)).toBeVisible();
    await expect(groups(page)).not.toContainText('Secret Dirty Dancing Shoes');
  });
});

test.describe('changing a password', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/dev/setup_discussion');
    await openOwnProfile(page);
    await page.locator('.user-page__change_password').click();
  });

  const changePassword = async (page, password, confirmation = password) => {
    await page.locator('.change-password-form__password input').fill(password);
    await page.locator('.change-password-form__password-confirmation input').fill(confirmation);
    await page.locator('.change-password-form__submit').click();
  };

  test('rejects a short password', async ({ page }) => {
    await changePassword(page, 'Smush');
    await expect(page.locator('.change-password-form__password-container .lmo-validation-error__message')).toContainText('is too short');
  });

  test('rejects mismatched passwords', async ({ page }) => {
    await changePassword(page, 'SmushDemBerries', 'SmishDemBorries');
    await expect(page.locator('.change-password-form__password-confirmation-container .lmo-validation-error__message')).toContainText("doesn't match");
  });

  test('sets a password', async ({ page, flash }) => {
    await changePassword(page, 'SmushDemBerries');
    await expect(flash).toContainText('Your password has been updated');
  });
});

test('deactivating the account signs you out', async ({ page }) => {
  await page.goto('/dev/setup_group_with_multiple_coordinators');
  await openOwnProfile(page);
  await page.locator('.user-page__redact_user').click();
  await page.locator('.confirm-modal__submit').click();
  await page.goto('/dashboard');
  await expect(signInModal(page)).toContainText('Sign in to Loomio');
});

test.describe('merging accounts', () => {
  test('confirms a merge from the verification email', async ({ page }) => {
    await page.goto('/dev/setup_merge_verification_email');
    await page.goto('/dev/last_email');
    await page.locator('.email-button').click();
    await page.locator('.btn--accent--raised').click();
    await expect(page.locator('.header')).toContainText('Merge successful!');
  });

  test('sending the verification email signs you out', async ({ page }) => {
    await page.goto('/dev/setup_discussion');
    await page.goto('/profile');
    await page.locator('.user-page__merge_accounts').click();
    const modal = page.locator('.merge-accounts-modal');
    await modal.locator('.merge-accounts-modal__destination-email input').fill('jennifer@example.com');
    await modal.locator('.merge-accounts-modal__submit').click();
    await expect(modal).toHaveCount(0);
    await page.goto('/dashboard');
    await expect(signInModal(page)).toContainText('Sign in to Loomio');
  });
});
