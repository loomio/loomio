import { test, expect } from '../fixtures.mjs';

test('successfully_updates_a_profile', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.goTo('profile')
  await page.waitFor('.profile-page__name-input input')

  await page.clearField('.profile-page__name-input input')
  await page.fillIn('.profile-page__name-input input', 'Ferris Bueller')
  await page.clearField('.profile-page__username-input input')
  await page.fillIn('.profile-page__username-input input', 'ferris_bueller-jr')
  await page.click('.profile-page .e2e-wysiwyg-btn')
  await page.waitFor('.profile-page .lmo-textarea div[contenteditable=true]')
  await page.fillIn('.profile-page .lmo-textarea div[contenteditable=true]', 'Save Ferris')
  await page.click('.profile-page__update-button')
  await page.expectFlash('Profile updated')

  await page.goTo('u/ferris_bueller-jr')
  await page.expectText('.user-page__content', 'Ferris Bueller')
  await page.expectText('.user-page__content', 'Save Ferris')
});

test('displays_a_user_and_their_non-secret_groups', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.goTo('u/jennifergrey')
  await page.expectText('.user-page__content', 'Jennifer Grey')
  await page.expectText('.user-page__content', '@jennifergrey')
  await page.expectText('.user-page__activity', 'What star sign are you?')
  await page.expectNoText('.user-page__activity', 'Jennifer Grey')
  await page.expectText('.user-page__groups', 'Dirty Dancing Shoes')
});

test('displays_secret_groups_to_other_members', async ({ lmo: page }) => {
  await page.loadPath('setup_profile_with_group_visible_to_members')
  await page.expectText('.user-page__groups', 'Secret Dirty Dancing Shoes')
});

test('does_not_display_secret_groups_to_visitors', async ({ lmo: page }) => {
  await page.loadPath('setup_restricted_profile')
  await page.expectNoText('.user-page__groups', 'Secret Dirty Dancing Shoes')
});

  // 'allows_you_to_contact_other_users': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_discussion')
  //   page.goTo('u/jennifergrey')
  //   page.click('.user-page__contact-user')
  //   page.fillIn('.contact-request-form__message textarea', 'Here is a request to connect!')
  //   page.click('.contact-request-form__submit')
  //   page.expectNoElement('.flash-root__loading', 1000)
  //   page.expectFlash('Email sent to Jennifer Grey')
  //
  //   page.goTo('u/patrickswayze')
  //   page.expectElement('.user-page')
  //   page.expectNoElement('.user-page__contact-user')
  // },

test('does_not_accept_short_passwords', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.pause()
  await page.ensureSidebar()
  await page.click('.sidebar__user-dropdown')
  await page.click('.user-dropdown__list-item-button--profile')
  await page.click('.user-page__change_password')
  await page.fillIn('.change-password-form__password input', 'Smush')
  await page.fillIn('.change-password-form__password-confirmation input', 'Smush')
  await page.click('.change-password-form__submit')
  await page.expectText('.change-password-form__password-container .lmo-validation-error__message', "is too short")
});

test('does_not_accept_mismatched_passwords', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.pause()
  await page.ensureSidebar()
  await page.click('.sidebar__user-dropdown')
  await page.click('.user-dropdown__list-item-button--profile')
  await page.click('.user-page__change_password')
  await page.fillIn('.change-password-form__password input', 'SmushDemBerries')
  await page.fillIn('.change-password-form__password-confirmation input', 'SmishDemBorries')
  await page.click('.change-password-form__submit')
  await page.expectText('.change-password-form__password-confirmation-container .lmo-validation-error__message', "doesn't match")
});

test('can_set_a_password', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.pause()
  await page.ensureSidebar()
  await page.click('.sidebar__user-dropdown')
  await page.click('.user-dropdown__list-item-button--profile')
  await page.click('.user-page__change_password')
  await page.fillIn('.change-password-form__password input', 'SmushDemBerries')
  await page.fillIn('.change-password-form__password-confirmation input', 'SmushDemBerries')
  await page.click('.change-password-form__submit')
  await page.expectFlash('Your password has been updated')
});

test('successfully_deactivates_the_account', async ({ lmo: page }) => {
  await page.loadPath('setup_group_with_multiple_coordinators')
  await page.pause(500)
  await page.ensureSidebar()

  await page.click('.sidebar__user-dropdown')
  await page.click('.user-dropdown__list-item-button--profile')
  await page.click('.user-page__redact_user')
  await page.click('.confirm-modal__submit')
  await page.pause(2000)
  await page.goTo('dashboard')
  await page.expectText('.auth-modal', 'Sign in to Loomio', 20000)
});

  // e2e broken, function works fine
  // 'merges_accounts': (test) => {
  //   page = pageHelper(test)
  //   page.loadPath('setup_group')
  //   page.pause(500)
  //   page.ensureSidebar()
  //   page.click('.sidebar__user-dropdown')
  //   page.click('.user-dropdown__list-item-button--profile')
  //   page.clear('.profile-page__email-input input')
  //   page.fillIn('.profile-page__email-input input', 'jennifer@example.com')
  //   page.expectElement('.profile-page__email-taken')
  //   page.click('.email-taken-find-out-more')
  //   page.click('.confirm-modal__submit')
  //   page.expectFlash('Verification email sent!')
  //   page.loadLastEmail()
  //   page.click('.email-button')
  //   page.pause()
  //   page.click('.btn--accent--raised')
  //   page.expectText('.header', "Merge successful!")
  // }

test('confirms_merge_accounts_from_email', async ({ lmo: page }) => {
  await page.loadPathNoApp('setup_merge_verification_email')
  await page.loadLastEmail()
  await page.click('.email-button')
  await page.pause(500)
  await page.expectElement('.btn--accent--raised')
  await page.click('.btn--accent--raised')
  await page.pause(500)
  await page.expectText('.header', 'Merge successful!')
});

test('signs_out_after_sending_merge_verification', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.goTo('profile')
  await page.click('.user-page__merge_accounts')
  await page.waitFor('.merge-accounts-modal')
  await page.fillIn('.merge-accounts-modal__destination-email input', 'jennifer@example.com')
  await page.click('.merge-accounts-modal__submit')

  // Sending the verification email signs the source account out.
  await page.pause(3000)
  await page.goTo('dashboard')
  await page.expectText('.auth-modal', 'Sign in to Loomio', 20000)
});

