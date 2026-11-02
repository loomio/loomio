import { test, expect } from '../screenshotFixtures.mjs';

test('group_overview', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await screenshot.captureElement('groups/group_page', '.group-page');
});

test('group_settings_menu', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.click('.group-page .action-menu--btn');
  await page.waitFor('.v-overlay .v-list');
  await screenshot.captureElement('groups/settings/group_settings', '.v-main', {
    spotlight: {
      selector: '.v-overlay .action-dock__button--edit_group',
      padding: 14,
      radius: 14,
      opacity: 0.4,
      outlineWidth: 0
    }
  });
});

test('group_settings_profile', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.click('.group-page .action-menu--btn');
  await page.waitFor('.v-overlay .action-dock__button--edit_group');
  await page.click('.v-overlay .action-dock__button--edit_group');
  await page.waitFor('.group-form');
  await page.expectValue('.group-form__name input', 'Oatmilk Cooperative');
  await page.expectValue('.group-form__handle input', 'oatmilk-cooperative');
  await screenshot.captureElement('groups/settings/group_profile', '.group-form', {height: 1000});
});

test('group_settings_privacy', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.click('.group-page .action-menu--btn');
  await page.waitFor('.v-overlay .action-dock__button--edit_group');
  await page.click('.v-overlay .action-dock__button--edit_group');
  await page.waitFor('.group-form');
  await page.click('.group-form__privacy-tab');
  await page.waitFor('.group-form__privacy');
  await page.execute("document.querySelector('.group-form__privacy-secret input').click()");
  await page.expectChecked('.group-form__privacy-secret input');
  await screenshot.captureElement('groups/settings/group_privacy_settings', '.group-form', {height: 800});
});

test('group_join_action', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_join_group');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.expectText('.join-group-button', 'Join group');
  await screenshot.capture('groups/settings/group_join_group', {
    spotlight: {
      selector: '.join-group-button',
      padding: 14,
      radius: 14,
      opacity: 0.4,
      outlineWidth: 0
    }
  });
});

test('group_invite_actions', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.click('.group-page-members-tab');
  await page.waitFor('.members-panel');
  await page.expectText('.membership-card__invite', 'Invite');
  await screenshot.capture('groups/settings/group_join_group_invite', {
    spotlight: {
      selector: '.membership-card__invite',
      padding: 14,
      radius: 14,
      opacity: 0.4,
      outlineWidth: 0
    }
  });
});

test('group_settings_permissions', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.click('.group-page .action-menu--btn');
  await page.waitFor('.v-overlay .action-dock__button--edit_group');
  await page.click('.v-overlay .action-dock__button--edit_group');
  await page.waitFor('.group-form');
  await page.click('.group-form__permissions-tab');
  await page.waitFor('.group-form__permissions');
  await screenshot.captureElement('groups/settings/group_group_settings_permissions', '.group-form', {height: 1400});
});

test('private_submissions_permission', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.click('.group-page .action-menu--btn');
  await page.waitFor('.v-overlay .action-dock__button--edit_group');
  await page.click('.v-overlay .action-dock__button--edit_group');
  await page.waitFor('.group-form');
  await page.click('.group-form__permissions-tab');
  await page.waitFor('.group-form__non-members-can-start-discussions');
  await screenshot.captureElement(
    'discussions/private_submissions/non_members_can_start_discussions',
    '.group-form',
    {
      height: 1400,
      spotlight: {
        selector: '.group-form__non-members-can-start-discussions',
        padding: 14,
        radius: 14,
        opacity: 0.4,
        outlineWidth: 0
      }
    }
  );
});

test('group_start_new', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.ensureSidebar();
  await page.expectElement('.sidebar-start-group');
  await screenshot.capture('groups/starting_a_group/new_group', {
    spotlight: {
      selector: '.sidebar-start-group',
      padding: 6,
      radius: 6
    }
  });
});

test('group_start_form', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.ensureSidebar();
  await page.click('.sidebar-start-group');
  await page.waitFor('.group-form');
  await page.fillIn('.group-form__name input', 'Oatmilk Producers Network');
  await page.expectValue('.group-form__handle input', 'oatmilk-producers-network');
  await page.click('.group-form__category-select .v-field');
  await page.waitFor('.v-overlay .v-select__content .v-list-item');
  await page.click('.v-overlay .group-form__category--self_managing');
  await page.fillIn(
    '.group-form__group-description .ProseMirror',
    'We coordinate shared purchasing, distribution, and training for regional oat milk producers.'
  );
  await page.expectValue('.group-form__name input', 'Oatmilk Producers Network');
  await screenshot.captureElement('groups/starting_a_group/new_group_start', '.group-form', {height: 1200});
});

test('discussion_intro', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_discussion_intro');
  await page.expectText('.context-panel__heading', 'Improve the cafe bottle return process');
  await page.waitFor('.topic-item__new-comment');
  await page.execute("document.querySelector('.v-app-bar').style.visibility = 'hidden'");
  await screenshot.captureRegion(
    'discussions/discussion-example',
    ['.topic-new-discussion', '.topic-item__new-comment', '.actions-panel'],
    {width: 1100, height: 1400, padding: 32, includeThreadGutters: true}
  );
});
