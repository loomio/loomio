import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

test('group_overview', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await screenshot.captureElement('groups/group_page', '.group-page');
});

test('group_settings_menu', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await page.locator('.group-page .action-menu--btn').click()
  await expect(page.locator('.v-overlay .v-list').first()).toBeVisible()
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

test('group_settings_profile', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await page.locator('.group-page .action-menu--btn').click()
  await page.locator('.v-overlay .action-dock__button--edit_group').click()
  await expect(page.locator('.group-form').first()).toBeVisible()
  await expect(page.locator('.group-form__name input')).toHaveValue('Oatmilk Cooperative')
  await expect(page.locator('.group-form__handle input')).toHaveValue('oatmilk-cooperative')
  await screenshot.captureElement('groups/settings/group_profile', '.group-form', {height: 1000});
});

test('group_settings_privacy', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await page.locator('.group-page .action-menu--btn').click()
  await page.locator('.v-overlay .action-dock__button--edit_group').click()
  await expect(page.locator('.group-form').first()).toBeVisible()
  await page.locator('.group-form__privacy-tab').click()
  await expect(page.locator('.group-form__privacy').first()).toBeVisible()
  await page.evaluate("document.querySelector('.group-form__privacy-secret input').click()")
  await expect(page.locator('.group-form__privacy-secret input')).toBeChecked()
  await screenshot.captureElement('groups/settings/group_privacy_settings', '.group-form', {height: 800});
});

test('group_join_action', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_join_group')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await expectLabel(page.locator('.join-group-button'), 'Join group')
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

test('group_invite_actions', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await page.locator('.group-page-members-tab').click()
  await expect(page.locator('.members-panel').first()).toBeVisible()
  await expectLabel(page.locator('.membership-card__invite'), 'Invite')
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

test('group_settings_permissions', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await page.locator('.group-page .action-menu--btn').click()
  await page.locator('.v-overlay .action-dock__button--edit_group').click()
  await expect(page.locator('.group-form').first()).toBeVisible()
  await page.locator('.group-form__permissions-tab').click()
  await expect(page.locator('.group-form__permissions').first()).toBeVisible()
  await screenshot.captureElement('groups/settings/group_group_settings_permissions', '.group-form', {height: 1400});
});

test('private_submissions_permission', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await page.locator('.group-page .action-menu--btn').click()
  await page.locator('.v-overlay .action-dock__button--edit_group').click()
  await expect(page.locator('.group-form').first()).toBeVisible()
  await page.locator('.group-form__permissions-tab').click()
  await expect(page.locator('.group-form__non-members-can-start-discussions').first()).toBeVisible()
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

test('group_start_new', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await page.locator('.navbar__sidenav-toggle').click()
  await expect(page.locator('.sidebar-start-group').first()).toBeVisible()
  await screenshot.capture('groups/starting_a_group/new_group', {
    spotlight: {
      selector: '.sidebar-start-group',
      padding: 6,
      radius: 6
    }
  });
});

test('group_start_form', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await page.locator('.navbar__sidenav-toggle').click()
  await page.locator('.sidebar-start-group').click()
  await expect(page.locator('.group-form').first()).toBeVisible()
  await page.locator('.group-form__name input').fill('Oatmilk Producers Network')
  await expect(page.locator('.group-form__handle input')).toHaveValue('oatmilk-producers-network')
  await page.locator('.group-form__category-select .v-field').click()
  await expect(page.locator('.v-overlay .v-select__content .v-list-item').first()).toBeVisible()
  await page.locator('.v-overlay .group-form__category--self_managing').click()
  await page.locator('.group-form__group-description .ProseMirror').fill('We coordinate shared purchasing, distribution, and training for regional oat milk producers.')
  await expect(page.locator('.group-form__name input')).toHaveValue('Oatmilk Producers Network')
  await screenshot.captureElement('groups/starting_a_group/new_group_start', '.group-form', {height: 1200});
});

test('discussion_intro', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_discussion_intro')
  await expectLabel(page.locator('.context-panel__heading'), 'Improve the cafe bottle return process')
  await expect(page.locator('.topic-item__new-comment').first()).toBeVisible()
  await page.evaluate("document.querySelector('.v-app-bar').style.visibility = 'hidden'")
  await screenshot.captureRegion(
    'discussions/discussion-example',
    ['.topic-new-discussion', '.topic-item__new-comment', '.actions-panel'],
    {width: 1100, height: 1400, padding: 32, includeThreadGutters: true}
  );
});
