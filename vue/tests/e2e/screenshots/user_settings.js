const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function useLightTheme(test) {
  test.chrome.sendDevToolsCommand('Emulation.setEmulatedMedia', {
    features: [{name: 'prefers-color-scheme', value: 'light'}]
  });
}

function openSidebar(page, settings = false) {
  page.clickAndWait('.navbar__sidenav-toggle', '.sidenav-left');
  if (settings) page.clickAndWait('.sidebar__user-dropdown', '.sidebar-close-settings');
}

function loadProfile(page) {
  page.loadPath('setup_manual_oatmilk_profile');
  page.waitFor('.profile-page');
}

function loadEmailSettings(page) {
  page.loadPath('setup_manual_oatmilk_email_settings');
  page.waitFor('.email-settings-page');
}

function loadMergeAccounts(page) {
  page.loadPath('setup_manual_oatmilk_merge_accounts');
  page.waitFor('.profile-page__email-input input');
  page.execute(`
    const input = document.querySelector('.profile-page__email-input input');
    input.value = 'jamie@oatmilk.example';
    input.dispatchEvent(new Event('input', {bubbles: true}));
    input.dispatchEvent(new Event('keyup', {bubbles: true}));
  `);
  page.waitFor('.profile-page__email-taken');
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'delete_user': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    loadProfile(page);
    screenshot.captureElement('users/deleting_your_account/delete_user', '.profile-page-card', {
      width: 1100,
      height: 900,
      spotlight: '.user-page__redact_user'
    });
  },

  'profile_edit': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    loadProfile(page);
    screenshot.captureElement('users/deleting_your_account/profile_edit', '.profile-page > div > .v-card:first-of-type', {width: 1100, height: 2200});
  },

  'merge_accounts_profile': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    loadMergeAccounts(page);
    screenshot.captureRegion(
      'users/merge_accounts/merge_accounts_profile',
      [
        '.profile-page > div > .v-card:first-of-type .v-card-title',
        '.profile-page__details > .d-sm-flex'
      ],
      {
        width: 1100,
        height: 1200,
        padding: 0,
        spotlight: {selectors: ['.profile-page__email-input', '.profile-page__email-taken']}
      }
    );
  },

  'merge_accounts_verify': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    loadMergeAccounts(page);
    page.clickAndWait('.email-taken-find-out-more', '.confirm-modal');
    screenshot.captureElement(
      'users/merge_accounts/merge_accounts_verify',
      '.confirm-modal',
      {width: 1100, height: 1000, spotlight: '.confirm-modal__submit'}
    );
  },

  'merge_accounts_email': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPathNoApp('setup_manual_oatmilk_merge_verification_email');
    page.waitFor('.base-mailer__button');
    screenshot.captureRegion(
      'users/merge_accounts/merge_accounts_email',
      ['.mailer__header', 'body > div:last-of-type'],
      {width: 1100, height: 1200, padding: 24, spotlight: '.base-mailer__button'}
    );
  },

  'merge_accounts_confirm': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPathNoApp('setup_manual_oatmilk_merge_verification_email');
    page.waitFor('.base-mailer__button');
    page.click('.base-mailer__button');
    page.waitFor('main.sistema');
    screenshot.captureElement(
      'users/merge_accounts/merge_accounts_confirm',
      'main.sistema',
      {width: 1100, height: 1000, spotlight: '.btn--accent--raised'}
    );
  },

  'permanently_delete_account': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    loadProfile(page);
    page.clickAndWait('.user-page__redact_user', '.confirm-modal');
    screenshot.captureElement('users/deleting_your_account/permanently_delete_account', '.confirm-modal', {width: 1100, height: 1400});
  },

  'reset_password': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    loadProfile(page);
    page.clickAndWait('.user-page__change_password', '.change-password-form');
    screenshot.captureElement('users/user_profile/reset_password', '.change-password-form', {width: 1100, height: 1200});
  },

  'notification_bell': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_all_notifications');
    page.waitFor('.notifications__button');
    screenshot.capture('users/email_settings/notification_bell', {
      width: 1100,
      height: 700,
      spotlight: '.notifications__button'
    });
  },

  'sidebar_notification_settings': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_group');
    openSidebar(page, true);
    screenshot.captureElement('users/email_settings/sidebar_notification_settings', '.sidenav-left', {
      width: 1100,
      height: 1200,
      spotlight: '.user-dropdown__list-item-button--email-settings'
    });
  },

  'email_settings': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    loadEmailSettings(page);
    screenshot.captureElement('users/email_settings/email_settings', '.email-settings-page__digest-card', {width: 1100, height: 1500});
  },

  'digest_email_setting': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    loadEmailSettings(page);
    page.click('.email-settings-page__digest-card .v-select .v-field__input');
    page.waitFor('.v-overlay--active .v-list');
    screenshot.captureRegion(
      'users/email_settings/digest_email_setting',
      ['.email-settings-page__digest-card .v-select .v-field', '.v-overlay--active .v-list'],
      {width: 1100, height: 1400, padding: 16}
    );
  },

  'proposal_invitation_email': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    useLightTheme(test);
    page.loadPathNoApp('setup_manual_oatmilk_proposal_invitation_email');
    page.waitFor('main');
    page.expectText('main', 'Run a six-week returnable bottle trial');
    screenshot.captureElement('users/email_settings/proposal_invitation_email', 'main', {width: 1100, height: 2600});
  },

  'proposal_outcome_email': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    useLightTheme(test);
    page.loadPathNoApp('setup_manual_oatmilk_proposal_outcome_email');
    page.waitFor('main');
    page.expectText('main', 'Run a six-week returnable bottle trial');
    screenshot.captureElement('users/email_settings/proposal_outcome_email', 'main', {width: 1100, height: 2800});
  },

  'digest_email_example': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    useLightTheme(test);
    page.loadPathNoApp('setup_manual_oatmilk_digest_email');
    page.waitFor('main');
    page.expectText('main', 'Notifications');
    page.expectText('main', 'Unread threads');
    screenshot.captureElement('users/email_settings/digest_email_example', 'main', {width: 1100, height: 2600});
  },

  'push_notification_settings': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_email_settings_with_push');
    page.waitFor('.push-notifications-settings-card--loaded');
    page.expectElement('.email-settings-page__push-column');
    screenshot.captureElement('users/email_settings/push_notification_settings', '.push-notifications-settings-card', {width: 1100, height: 1400});
  },

  'group_notifications': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_group');
    page.waitFor('.group-page');
    page.clickAndWait('.group-page .action-menu--btn', '.v-overlay--active .v-list');
    screenshot.capture('users/email_settings/group_notifications', {
      width: 1100,
      height: 1200,
      spotlight: '.v-overlay--active .action-dock__button--change_volume'
    });
  },

  'group_notification_settings': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_group');
    page.waitFor('.group-page');
    page.clickAndWait('.group-page .action-menu--btn', '.v-overlay--active .v-list');
    page.clickAndWait('.v-overlay--active .action-dock__button--change_volume', '.change-volume-form');
    page.waitFor('.change-volume-form--push-disabled');
    screenshot.captureElement('users/email_settings/group_notification_settings', '.change-volume-form', {width: 1100, height: 1300});
  },

  'thread_subscribe': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_discussion');
    page.waitFor('.topic-sidebar');
    page.waitFor('.topic-sidebar__notification-settings');
    screenshot.captureElement('users/email_settings/thread_subscribe', '.topic-sidebar', {
      width: 1100,
      height: 1500,
      spotlight: '.topic-sidebar__notification-settings'
    });
  },

  'thread_notifications': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_discussion');
    page.waitFor('.topic-sidebar');
    page.clickAndWait('.topic-sidebar__notification-settings', '.change-volume-form');
    page.waitFor('.change-volume-form--push-disabled');
    screenshot.captureElement('users/email_settings/thread_notifications', '.change-volume-form', {width: 1100, height: 1300});
  },

  'thread_notifications_email_catch_up_push': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_discussion_with_push');
    page.waitFor('.topic-sidebar');
    page.clickAndWait('.topic-sidebar__notification-settings', '.change-volume-form');
    page.waitFor('.change-volume-form--push-enabled');
    screenshot.captureElement('users/email_settings/thread_notifications_email_catch_up_push', '.change-volume-form', {width: 1100, height: 1800});
  },

  'turn_off_all_emails_1': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    loadEmailSettings(page);
    screenshot.captureElement('users/email_settings/turn_off_all_emails_1', '.email-settings-page__digest-card', {
      width: 1100,
      height: 1500,
      spotlight: {selectors: ['#mentioned-email', '#on-participation-email', '#digest-email-day']}
    });
  },

  'turn_off_all_emails_2': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    loadEmailSettings(page);
    page.waitFor('.email-settings-page__push-status-loaded');
    page.expectNoElement('.email-settings-page__push-column');
    screenshot.captureElement('users/email_settings/turn_off_all_emails_2', '.email-settings-page__group-notifications-card', {
      width: 1100,
      height: 1800,
      spotlight: '.email-settings-page__group-notifications-card tbody'
    });
  },

  'change_language': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    loadProfile(page);
    screenshot.captureElement('users/translation/change_language', '.profile-page > div > .v-card:first-of-type', {
      width: 1100,
      height: 2200,
      spotlight: '#user-locale-field'
    });
  },

  'content_translation': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_translated_comment');
    page.waitFor('.topic-item__new-comment', 15000);
    screenshot.captureRegion(
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
    page.click('.action-dock__button--translate_comment');
    page.expectText('.topic-item__new-comment', 'I can ask three cafes to track how many bottles are returned each week.');
    screenshot.captureRegion(
      'users/translation/content_translated',
      ['.topic-item__new-comment'],
      {width: 1100, height: 1200, padding: 4, includeThreadGutters: true}
    );
  },

  'automatic_translation': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    loadProfile(page);
    page.execute(`
      const control = Array.from(document.querySelectorAll('.profile-page .v-checkbox'))
        .find((element) => element.textContent.includes('Translate content to my language automatically'));
      control?.classList.add('manual-automatic-translation');
    `);
    page.waitFor('.manual-automatic-translation');
    screenshot.captureElement(
      'users/translation/automatic_translation',
      '.profile-page > div > .v-card:first-of-type',
      {
        width: 1100,
        height: 2200,
        spotlight: '.manual-automatic-translation'
      }
    );
  },

  'sidebar_menu': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_group');
    screenshot.capture('users/user_profile/sidebar_menu', {
      width: 1100,
      height: 700,
      spotlight: '.navbar__sidenav-toggle'
    });
  },

  'sidebar_profile': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_group');
    openSidebar(page);
    screenshot.captureElement('users/user_profile/sidebar_profile', '.sidenav-left', {
      width: 1100,
      height: 1200,
      spotlight: '.sidebar__user-dropdown'
    });
  },

  'edit_profile': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_group');
    openSidebar(page, true);
    screenshot.captureElement('users/user_profile/edit_profile', '.sidenav-left', {
      width: 1100,
      height: 1200,
      spotlight: '.user-dropdown__list-item-button--profile'
    });
  },

  'user_profile': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    loadProfile(page);
    screenshot.captureElement('users/user_profile/user_profile', '.profile-page > div > .v-card:first-of-type', {width: 1100, height: 2200});
  },

  'profile_photo': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    loadProfile(page);
    page.clickAndWait('.profile-page__avatar', '.change-picture-form');
    screenshot.captureElement('users/user_profile/profile_photo', '.change-picture-form', {width: 1100, height: 1300});
  },

  'profile_language': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    loadProfile(page);
    page.execute("document.querySelector('#user-locale-field').scrollIntoView({block: 'center'})");
    page.pause(200);
    screenshot.captureElement('users/user_profile/profile_language', '#user-locale-field', {
      width: 1100,
      height: 900,
      spotlight: '#user-locale-field'
    });
  }
};
