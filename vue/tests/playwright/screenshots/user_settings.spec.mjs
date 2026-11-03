import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

async function useLightTheme(page) {
  await page.emulateMedia({ colorScheme: 'light' });
}

// The drawer can already be open, for example on a wide viewport or when an
// earlier test left it open, and clicking the toggle would then close it.
async function openSidebar(page, settings = false) {
  await expect(page.locator('.navbar__sidenav-toggle').first()).toBeVisible()
  await page.evaluate("if (!document.querySelector('.sidenav-left.v-navigation-drawer--active')) document.querySelector('.navbar__sidenav-toggle').click()")
  await expect(page.locator('.sidenav-left').first()).toBeVisible()
  if (settings) { await page.locator('.sidebar__user-dropdown').click(); }
}

async function loadProfile(page) {
  await page.goto('/dev/setup_manual_oatmilk_profile')
  await expect(page.locator('.profile-page').first()).toBeVisible()
}

async function loadEmailSettings(page) {
  await page.goto('/dev/setup_manual_oatmilk_email_settings')
  await expect(page.locator('.email-settings-page').first()).toBeVisible()
}

async function loadMergeAccounts(page) {
  await page.goto('/dev/setup_manual_oatmilk_merge_accounts')
  await expect(page.locator('.user-page__merge_accounts').first()).toBeVisible()
}

test('delete_user', async ({ page, manual: screenshot }) => {
  await loadProfile(page);
  await screenshot.captureElement('users/deleting_your_account/delete_user', '.profile-page-card', {
    width: 1100,
    height: 900,
    spotlight: '.user-page__redact_user'
  });
});

test('profile_edit', async ({ page, manual: screenshot }) => {
  await loadProfile(page);
  await screenshot.captureElement('users/deleting_your_account/profile_edit', '.profile-page > div > .v-card:first-of-type', {width: 1100, height: 2200});
});

test('merge_accounts_profile', async ({ page, manual: screenshot }) => {
  await loadMergeAccounts(page);
  await screenshot.captureElement('users/merge_accounts/merge_accounts_profile', '.profile-page-card', {
    width: 1100,
    height: 900,
    spotlight: '.user-page__merge_accounts'
  });
});

test('merge_accounts_verify', async ({ page, manual: screenshot }) => {
  await loadMergeAccounts(page);
  await page.locator('.user-page__merge_accounts').click()
  await page.locator('.merge-accounts-modal__destination-email input').pressSequentially('jamie@oatmilk.example')
  await screenshot.captureElement(
    'users/merge_accounts/merge_accounts_verify',
    '.merge-accounts-modal',
    {width: 1100, height: 1000, spotlight: '.merge-accounts-modal__submit'}
  );
});

test('merge_accounts_email', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_merge_verification_email')
  await expect(page.locator('.email-button').first()).toBeVisible()
  await screenshot.captureRegion(
    'users/merge_accounts/merge_accounts_email',
    ['.email-header', '.email-button'],
    {width: 1100, height: 1200, padding: 24, spotlight: '.email-button'}
  );
});

test('merge_accounts_confirm', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_merge_verification_email')
  await page.locator('.email-button').click()
  await expect(page.locator('main.sistema').first()).toBeVisible()
  await screenshot.captureElement(
    'users/merge_accounts/merge_accounts_confirm',
    'main.sistema',
    {width: 1100, height: 1000, spotlight: '.btn--accent--raised'}
  );
});

test('permanently_delete_account', async ({ page, manual: screenshot }) => {
  await loadProfile(page);
  await page.locator('.user-page__redact_user').click()
  await screenshot.captureElement('users/deleting_your_account/permanently_delete_account', '.confirm-modal', {width: 1100, height: 1400});
});

test('reset_password', async ({ page, manual: screenshot }) => {
  await loadProfile(page);
  await page.locator('.user-page__change_password').click()
  await screenshot.captureElement('users/user_profile/reset_password', '.change-password-form', {width: 1100, height: 1200});
});

test('notification_bell', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_all_notifications')
  await expect(page.locator('.notifications__button').first()).toBeVisible()
  await screenshot.capture('users/email_settings/notification_bell', {
    width: 1100,
    height: 700,
    spotlight: '.notifications__button'
  });
});

test('sidebar_notification_settings', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await openSidebar(page, true);
  await screenshot.captureElement('users/email_settings/sidebar_notification_settings', '.sidenav-left', {
    width: 1100,
    height: 1200,
    spotlight: '.user-dropdown__list-item-button--email-settings'
  });
});

test('email_settings', async ({ page, manual: screenshot }) => {
  await loadEmailSettings(page);
  await screenshot.captureElement('users/email_settings/email_settings', '.email-settings-page__digest-card', {width: 1100, height: 1500});
});

test('digest_email_setting', async ({ page, manual: screenshot }) => {
  await loadEmailSettings(page);
  await page.locator('.email-settings-page__digest-card .v-select .v-field__input').click()
  await expect(page.locator('.v-overlay--active .v-list').first()).toBeVisible()
  await screenshot.captureRegion(
    'users/email_settings/digest_email_setting',
    ['.email-settings-page__digest-card .v-select .v-field', '.v-overlay--active .v-list'],
    {width: 1100, height: 1400, padding: 16}
  );
});

test('proposal_invitation_email', async ({ page, manual: screenshot }) => {
  await useLightTheme(page);
  await page.goto('/dev/setup_manual_oatmilk_proposal_invitation_email')
  await expect(page.locator('main').first()).toBeVisible()
  await expectLabel(page.locator('main'), 'Run a six-week returnable bottle trial')
  await screenshot.captureElement('users/email_settings/proposal_invitation_email', 'main', {width: 1100, height: 2600});
});

test('proposal_outcome_email', async ({ page, manual: screenshot }) => {
  await useLightTheme(page);
  await page.goto('/dev/setup_manual_oatmilk_proposal_outcome_email')
  await expect(page.locator('main').first()).toBeVisible()
  await expectLabel(page.locator('main'), 'Run a six-week returnable bottle trial')
  await screenshot.captureElement('users/email_settings/proposal_outcome_email', 'main', {width: 1100, height: 2800});
});

test('digest_email_example', async ({ page, manual: screenshot }) => {
  await useLightTheme(page);
  await page.goto('/dev/setup_manual_oatmilk_digest_email')
  await expect(page.locator('main').first()).toBeVisible()
  await expectLabel(page.locator('main'), 'Notifications')
  await expectLabel(page.locator('main'), 'Unread threads')
  await screenshot.captureElement('users/email_settings/digest_email_example', 'main', {width: 1100, height: 2600});
});

test('push_notification_settings', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_email_settings_with_push')
  await expect(page.locator('.push-notifications-settings-card--loaded').first()).toBeVisible()
  await expect(page.locator('.email-settings-page__push-column').first()).toBeVisible()
  await screenshot.captureElement('users/email_settings/push_notification_settings', '.push-notifications-settings-card', {width: 1100, height: 1400});
});

test('group_notifications', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await expect(page.locator('.group-page').first()).toBeVisible()
  await page.locator('.group-page .action-menu--btn').click()
  await screenshot.capture('users/email_settings/group_notifications', {
    width: 1100,
    height: 1200,
    spotlight: '.v-overlay--active .action-dock__button--change_volume'
  });
});

test('group_notification_settings', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await expect(page.locator('.group-page').first()).toBeVisible()
  await page.locator('.group-page .action-menu--btn').click()
  await page.locator('.v-overlay--active .action-dock__button--change_volume').click()
  await expect(page.locator('.change-volume-form--push-disabled').first()).toBeVisible()
  await screenshot.captureElement('users/email_settings/group_notification_settings', '.change-volume-form', {width: 1100, height: 1300});
});

test('group_follow_updates', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_join_group')
  await expect(page.locator('.group-follow-button').first()).toBeVisible()
  await expectLabel(page.locator('.group-follow-button'), 'Follow updates')
  await screenshot.captureRegion('groups/settings/group_follow_updates', ['.group-page > div:first-child', '.group-follow-button'], {
    width: 1100,
    height: 1800,
    padding: 0,
    spotlight: '.group-follow-button'
  });
});

test('thread_subscribe', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_discussion')
  await expect(page.locator('.topic-sidebar').first()).toBeVisible()
  await expect(page.locator('.topic-sidebar__notification-settings').first()).toBeVisible()
  await screenshot.captureElement('users/email_settings/thread_subscribe', '.topic-sidebar', {
    width: 1100,
    height: 1500,
    spotlight: '.topic-sidebar__notification-settings'
  });
});

test('thread_notifications', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_discussion')
  await expect(page.locator('.topic-sidebar').first()).toBeVisible()
  await page.locator('.topic-sidebar__notification-settings').click()
  await expect(page.locator('.change-volume-form--push-disabled').first()).toBeVisible()
  await screenshot.captureElement('users/email_settings/thread_notifications', '.change-volume-form', {width: 1100, height: 1300});
});

test('thread_notifications_email_catch_up_push', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_discussion_with_push')
  await expect(page.locator('.topic-sidebar').first()).toBeVisible()
  await page.locator('.topic-sidebar__notification-settings').click()
  await expect(page.locator('.change-volume-form--push-enabled').first()).toBeVisible()
  await screenshot.captureElement('users/email_settings/thread_notifications_email_catch_up_push', '.change-volume-form', {width: 1100, height: 1800});
});

test('turn_off_all_emails_1', async ({ page, manual: screenshot }) => {
  await loadEmailSettings(page);
  await page.locator('.email-settings-page__digest-card .v-select .v-field').click()
  await expect(page.locator('.v-overlay--active .v-list').first()).toBeVisible()
  await page.locator('.v-overlay--active .email-settings-page__catch-up-day--never').click()
  await screenshot.captureElement('users/email_settings/turn_off_all_emails_1', '.email-settings-page__digest-card', {
    width: 1100,
    height: 1500,
    spotlight: '#digest-email-day'
  });
});

test('turn_off_all_emails_2', async ({ page, manual: screenshot }) => {
  await loadEmailSettings(page);
  await expect(page.locator('.email-settings-page__push-status-loaded').first()).toBeVisible()
  await expect(page.locator('.email-settings-page__push-column')).toHaveCount(0)
  await screenshot.captureElement('users/email_settings/turn_off_all_emails_2', '.email-settings-page__group-notifications-card', {
    width: 1100,
    height: 1800,
    spotlight: '.email-settings-page__group-notifications-card tbody'
  });
});

test('change_language', async ({ page, manual: screenshot }) => {
  await loadProfile(page);
  await screenshot.captureElement('users/translation/change_language', '.profile-page > div > .v-card:first-of-type', {
    width: 1100,
    height: 2200,
    spotlight: '#user-locale-field'
  });
});

test('content_translation', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_translated_comment')
  await expect(page.locator('.topic-item__new-comment').first()).toBeVisible({ timeout: 15000 })
  await screenshot.captureRegion(
    'users/translation/content_translation',
    ['.topic-item__new-comment'],
    {
      width: 1100,
      height: 1200,
      padding: 4,
      includeThreadGutters: true,
      spotlight: '.action-dock__button--translate_comment'
    }
  );
  await page.locator('.action-dock__button--translate_comment').click()
  await expectLabel(page.locator('.topic-item__new-comment'), 'I can ask three cafes to track how many bottles are returned each week.')
  await screenshot.captureRegion(
    'users/translation/content_translated',
    ['.topic-item__new-comment'],
    {width: 1100, height: 1200, padding: 4, includeThreadGutters: true}
  );
});

test('automatic_translation', async ({ page, manual: screenshot }) => {
  await loadProfile(page);
  await page.evaluate(`
    document.querySelector('.profile-page .profile-page__auto-translate').classList.add('manual-automatic-translation');
  `)
  await expect(page.locator('.manual-automatic-translation').first()).toBeVisible()
  await screenshot.captureElement(
    'users/translation/automatic_translation',
    '.profile-page > div > .v-card:first-of-type',
    {
      width: 1100,
      height: 2200,
      spotlight: '.manual-automatic-translation'
    }
  );
});

test('sidebar_menu', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await screenshot.capture('users/user_profile/sidebar_menu', {
    width: 1100,
    height: 700,
    spotlight: '.navbar__sidenav-toggle'
  });
});

test('sidebar_profile', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await openSidebar(page);
  await screenshot.captureElement('users/user_profile/sidebar_profile', '.sidenav-left', {
    width: 1100,
    height: 1200,
    spotlight: '.sidebar__user-dropdown'
  });
});

test('edit_profile', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await openSidebar(page, true);
  await screenshot.captureRegion('users/user_profile/edit_profile', [
    '.sidebar-close-settings',
    '.user-dropdown__list-item-button--sign-out'
  ], {
    width: 1100,
    height: 1200,
    padding: 12,
    spotlight: '.user-dropdown__list-item-button--profile'
  });
});

test('user_profile', async ({ page, manual: screenshot }) => {
  await loadProfile(page);
  await screenshot.captureElement('users/user_profile/user_profile', '.profile-page > div > .v-card:first-of-type', {width: 1100, height: 2200});
});

test('profile_photo', async ({ page, manual: screenshot }) => {
  await loadProfile(page);
  await page.locator('.profile-page__avatar').click()
  await screenshot.captureElement('users/user_profile/profile_photo', '.change-picture-form', {width: 1100, height: 1300});
});
