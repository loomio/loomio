import { test, expect } from '../screenshotFixtures.mjs';

async function useLightTheme(page) {
  await page.page.emulateMedia({ colorScheme: 'light' });
}

// The drawer can already be open, for example on a wide viewport or when an
// earlier test left it open, and clicking the toggle would then close it.
async function openSidebar(page, settings = false) {
  await page.waitFor('.navbar__sidenav-toggle');
  await page.pause(500);
  await page.execute("if (!document.querySelector('.sidenav-left.v-navigation-drawer--active')) document.querySelector('.navbar__sidenav-toggle').click()");
  await page.waitFor('.sidenav-left');
  if (settings) page.clickAndWait('.sidebar__user-dropdown', '.sidebar-close-settings');
}

async function loadProfile(page) {
  await page.loadPath('setup_manual_oatmilk_profile');
  await page.waitFor('.profile-page');
}

async function loadEmailSettings(page) {
  await page.loadPath('setup_manual_oatmilk_email_settings');
  await page.waitFor('.email-settings-page');
}

async function loadMergeAccounts(page) {
  await page.loadPath('setup_manual_oatmilk_merge_accounts');
  await page.waitFor('.user-page__merge_accounts');
}

test('delete_user', async ({ lmo: page, manual: screenshot }) => {
  await loadProfile(page);
  await screenshot.captureElement('users/deleting_your_account/delete_user', '.profile-page-card', {
    width: 1100,
    height: 900,
    spotlight: '.user-page__redact_user'
  });
});

test('profile_edit', async ({ lmo: page, manual: screenshot }) => {
  await loadProfile(page);
  await screenshot.captureElement('users/deleting_your_account/profile_edit', '.profile-page > div > .v-card:first-of-type', {width: 1100, height: 2200});
});

test('merge_accounts_profile', async ({ lmo: page, manual: screenshot }) => {
  await loadMergeAccounts(page);
  await screenshot.captureElement('users/merge_accounts/merge_accounts_profile', '.profile-page-card', {
    width: 1100,
    height: 900,
    spotlight: '.user-page__merge_accounts'
  });
});

test('merge_accounts_verify', async ({ lmo: page, manual: screenshot }) => {
  await loadMergeAccounts(page);
  await page.clickAndWait('.user-page__merge_accounts', '.merge-accounts-modal');
  await page.fillIn('.merge-accounts-modal__destination-email input', 'jamie@oatmilk.example');
  await screenshot.captureElement(
    'users/merge_accounts/merge_accounts_verify',
    '.merge-accounts-modal',
    {width: 1100, height: 1000, spotlight: '.merge-accounts-modal__submit'}
  );
});

test('merge_accounts_email', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPathNoApp('setup_manual_oatmilk_merge_verification_email');
  await page.waitFor('.email-button');
  await screenshot.captureRegion(
    'users/merge_accounts/merge_accounts_email',
    ['.email-header', '.email-button'],
    {width: 1100, height: 1200, padding: 24, spotlight: '.email-button'}
  );
});

test('merge_accounts_confirm', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPathNoApp('setup_manual_oatmilk_merge_verification_email');
  await page.waitFor('.email-button');
  await page.click('.email-button');
  await page.waitFor('main.sistema');
  await screenshot.captureElement(
    'users/merge_accounts/merge_accounts_confirm',
    'main.sistema',
    {width: 1100, height: 1000, spotlight: '.btn--accent--raised'}
  );
});

test('permanently_delete_account', async ({ lmo: page, manual: screenshot }) => {
  await loadProfile(page);
  await page.clickAndWait('.user-page__redact_user', '.confirm-modal');
  await screenshot.captureElement('users/deleting_your_account/permanently_delete_account', '.confirm-modal', {width: 1100, height: 1400});
});

test('reset_password', async ({ lmo: page, manual: screenshot }) => {
  await loadProfile(page);
  await page.clickAndWait('.user-page__change_password', '.change-password-form');
  await screenshot.captureElement('users/user_profile/reset_password', '.change-password-form', {width: 1100, height: 1200});
});

test('notification_bell', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_all_notifications');
  await page.waitFor('.notifications__button');
  await screenshot.capture('users/email_settings/notification_bell', {
    width: 1100,
    height: 700,
    spotlight: '.notifications__button'
  });
});

test('sidebar_notification_settings', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
  await openSidebar(page, true);
  await screenshot.captureElement('users/email_settings/sidebar_notification_settings', '.sidenav-left', {
    width: 1100,
    height: 1200,
    spotlight: '.user-dropdown__list-item-button--email-settings'
  });
});

test('email_settings', async ({ lmo: page, manual: screenshot }) => {
  await loadEmailSettings(page);
  await screenshot.captureElement('users/email_settings/email_settings', '.email-settings-page__digest-card', {width: 1100, height: 1500});
});

test('digest_email_setting', async ({ lmo: page, manual: screenshot }) => {
  await loadEmailSettings(page);
  await page.click('.email-settings-page__digest-card .v-select .v-field__input');
  await page.waitFor('.v-overlay--active .v-list');
  await screenshot.captureRegion(
    'users/email_settings/digest_email_setting',
    ['.email-settings-page__digest-card .v-select .v-field', '.v-overlay--active .v-list'],
    {width: 1100, height: 1400, padding: 16}
  );
});

test('proposal_invitation_email', async ({ lmo: page, manual: screenshot }) => {
  await useLightTheme(page);
  await page.loadPathNoApp('setup_manual_oatmilk_proposal_invitation_email');
  await page.waitFor('main');
  await page.expectText('main', 'Run a six-week returnable bottle trial');
  await screenshot.captureElement('users/email_settings/proposal_invitation_email', 'main', {width: 1100, height: 2600});
});

test('proposal_outcome_email', async ({ lmo: page, manual: screenshot }) => {
  await useLightTheme(page);
  await page.loadPathNoApp('setup_manual_oatmilk_proposal_outcome_email');
  await page.waitFor('main');
  await page.expectText('main', 'Run a six-week returnable bottle trial');
  await screenshot.captureElement('users/email_settings/proposal_outcome_email', 'main', {width: 1100, height: 2800});
});

test('digest_email_example', async ({ lmo: page, manual: screenshot }) => {
  await useLightTheme(page);
  await page.loadPathNoApp('setup_manual_oatmilk_digest_email');
  await page.waitFor('main');
  await page.expectText('main', 'Notifications');
  await page.expectText('main', 'Unread threads');
  await screenshot.captureElement('users/email_settings/digest_email_example', 'main', {width: 1100, height: 2600});
});

test('push_notification_settings', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_email_settings_with_push');
  await page.waitFor('.push-notifications-settings-card--loaded');
  await page.expectElement('.email-settings-page__push-column');
  await screenshot.captureElement('users/email_settings/push_notification_settings', '.push-notifications-settings-card', {width: 1100, height: 1400});
});

test('group_notifications', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.waitFor('.group-page');
  await page.clickAndWait('.group-page .action-menu--btn', '.v-overlay--active .v-list');
  await screenshot.capture('users/email_settings/group_notifications', {
    width: 1100,
    height: 1200,
    spotlight: '.v-overlay--active .action-dock__button--change_volume'
  });
});

test('group_notification_settings', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.waitFor('.group-page');
  await page.clickAndWait('.group-page .action-menu--btn', '.v-overlay--active .v-list');
  await page.clickAndWait('.v-overlay--active .action-dock__button--change_volume', '.change-volume-form');
  await page.waitFor('.change-volume-form--push-disabled');
  await screenshot.captureElement('users/email_settings/group_notification_settings', '.change-volume-form', {width: 1100, height: 1300});
});

test('group_follow_updates', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_join_group');
  await page.waitFor('.group-follow-button');
  await page.expectText('.group-follow-button', 'Follow updates');
  await screenshot.captureRegion('groups/settings/group_follow_updates', ['.group-page > div:first-child', '.group-follow-button'], {
    width: 1100,
    height: 1800,
    padding: 0,
    spotlight: '.group-follow-button'
  });
});

test('thread_subscribe', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_discussion');
  await page.waitFor('.topic-sidebar');
  await page.waitFor('.topic-sidebar__notification-settings');
  await screenshot.captureElement('users/email_settings/thread_subscribe', '.topic-sidebar', {
    width: 1100,
    height: 1500,
    spotlight: '.topic-sidebar__notification-settings'
  });
});

test('thread_notifications', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_discussion');
  await page.waitFor('.topic-sidebar');
  await page.clickAndWait('.topic-sidebar__notification-settings', '.change-volume-form');
  await page.waitFor('.change-volume-form--push-disabled');
  await screenshot.captureElement('users/email_settings/thread_notifications', '.change-volume-form', {width: 1100, height: 1300});
});

test('thread_notifications_email_catch_up_push', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_discussion_with_push');
  await page.waitFor('.topic-sidebar');
  await page.clickAndWait('.topic-sidebar__notification-settings', '.change-volume-form');
  await page.waitFor('.change-volume-form--push-enabled');
  await screenshot.captureElement('users/email_settings/thread_notifications_email_catch_up_push', '.change-volume-form', {width: 1100, height: 1800});
});

test('turn_off_all_emails_1', async ({ lmo: page, manual: screenshot }) => {
  await loadEmailSettings(page);
  await page.click('.email-settings-page__digest-card .v-select .v-field');
  await page.waitFor('.v-overlay--active .v-list');
  await page.click('.v-overlay--active .email-settings-page__catch-up-day--never');
  await screenshot.captureElement('users/email_settings/turn_off_all_emails_1', '.email-settings-page__digest-card', {
    width: 1100,
    height: 1500,
    spotlight: '#digest-email-day'
  });
});

test('turn_off_all_emails_2', async ({ lmo: page, manual: screenshot }) => {
  await loadEmailSettings(page);
  await page.waitFor('.email-settings-page__push-status-loaded');
  await page.expectNoElement('.email-settings-page__push-column');
  await screenshot.captureElement('users/email_settings/turn_off_all_emails_2', '.email-settings-page__group-notifications-card', {
    width: 1100,
    height: 1800,
    spotlight: '.email-settings-page__group-notifications-card tbody'
  });
});

test('change_language', async ({ lmo: page, manual: screenshot }) => {
  await loadProfile(page);
  await screenshot.captureElement('users/translation/change_language', '.profile-page > div > .v-card:first-of-type', {
    width: 1100,
    height: 2200,
    spotlight: '#user-locale-field'
  });
});

test('content_translation', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_translated_comment');
  await page.waitFor('.topic-item__new-comment', 15000);
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
  await page.click('.action-dock__button--translate_comment');
  await page.expectText('.topic-item__new-comment', 'I can ask three cafes to track how many bottles are returned each week.');
  await screenshot.captureRegion(
    'users/translation/content_translated',
    ['.topic-item__new-comment'],
    {width: 1100, height: 1200, padding: 4, includeThreadGutters: true}
  );
});

test('automatic_translation', async ({ lmo: page, manual: screenshot }) => {
  await loadProfile(page);
  await page.execute(`
    document.querySelector('.profile-page .profile-page__auto-translate').classList.add('manual-automatic-translation');
  `);
  await page.waitFor('.manual-automatic-translation');
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

test('sidebar_menu', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
  await screenshot.capture('users/user_profile/sidebar_menu', {
    width: 1100,
    height: 700,
    spotlight: '.navbar__sidenav-toggle'
  });
});

test('sidebar_profile', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
  await openSidebar(page);
  await screenshot.captureElement('users/user_profile/sidebar_profile', '.sidenav-left', {
    width: 1100,
    height: 1200,
    spotlight: '.sidebar__user-dropdown'
  });
});

test('edit_profile', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
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

test('user_profile', async ({ lmo: page, manual: screenshot }) => {
  await loadProfile(page);
  await screenshot.captureElement('users/user_profile/user_profile', '.profile-page > div > .v-card:first-of-type', {width: 1100, height: 2200});
});

test('profile_photo', async ({ lmo: page, manual: screenshot }) => {
  await loadProfile(page);
  await page.clickAndWait('.profile-page__avatar', '.change-picture-form');
  await screenshot.captureElement('users/user_profile/profile_photo', '.change-picture-form', {width: 1100, height: 1300});
});
