import { test, expect, expectLabel } from '../screenshotFixtures.mjs';
import { editor } from '../helpers/editor.mjs';
import { ensureSidebar } from '../helpers/groups.mjs';

const menuSpotlight = selector => ({ selector, padding: 14, radius: 14, opacity: 0.4, outlineWidth: 0 });

async function openGroup(page) {
  await page.goto('/dev/setup_manual_oatmilk_group');
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative');
}

async function openGroupMenu(page) {
  await openGroup(page);
  await page.locator('.group-page__actions .action-menu--btn').click();
}

// Opens the group settings form, on a tab other than the profile when given.
async function openGroupSettings(page, tab) {
  await openGroupMenu(page);
  await page.locator('.v-overlay--active .action-dock__button--edit_group').click();
  await expect(page.locator('.group-form')).toBeVisible();
  if (tab) { await page.locator(`.group-form__${tab}-tab`).click(); }
}

test('group_overview', async ({ page, manual: screenshot }) => {
  await openGroup(page);
  await screenshot.captureElement('groups/group_page', '.group-page');
});

test('group_settings_menu', async ({ page, manual: screenshot }) => {
  await openGroupMenu(page);
  await expect(page.locator('.v-overlay--active .action-dock__button--edit_group')).toBeVisible();
  await screenshot.captureElement('groups/settings/group_settings', '.v-main', {
    height: 757,
    spotlight: menuSpotlight('.v-overlay .action-dock__button--edit_group')
  });
});

test('group_settings_profile', async ({ page, manual: screenshot }) => {
  await openGroupSettings(page);
  await expect(page.locator('.group-form__name input')).toHaveValue('Oatmilk Cooperative');
  await expect(page.locator('.group-form__handle input')).toHaveValue('oatmilk-cooperative');
  await screenshot.captureElement('groups/settings/group_profile', '.group-form', { height: 1000 });
});

test('group_settings_privacy', async ({ page, manual: screenshot }) => {
  await openGroupSettings(page, 'privacy');
  await page.locator('.group-form__privacy-secret input').check();
  await screenshot.captureElement('groups/settings/group_privacy_settings', '.group-form', { height: 800 });
});

test('group_join_action', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_join_group');
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative');
  await expectLabel(page.locator('.join-group-button'), 'Join group');
  await screenshot.capture('groups/settings/group_join_group', {
    spotlight: menuSpotlight('.join-group-button')
  });
});

test('group_invite_actions', async ({ page, manual: screenshot }) => {
  await openGroup(page);
  await page.locator('.group-page-members-tab').click();
  await expect(page.locator('.members-panel')).toBeVisible();
  await expectLabel(page.locator('.membership-card__invite'), 'Invite');
  await screenshot.capture('groups/settings/group_join_group_invite', {
    spotlight: menuSpotlight('.membership-card__invite')
  });
});

test('group_settings_permissions', async ({ page, manual: screenshot }) => {
  await openGroupSettings(page, 'permissions');
  await expect(page.locator('.group-form__permissions')).toBeVisible();
  await screenshot.captureElement('groups/settings/group_group_settings_permissions', '.group-form', { height: 1400 });
});

test('private_submissions_permission', async ({ page, manual: screenshot }) => {
  await openGroupSettings(page, 'permissions');
  await expect(page.locator('.group-form__non-members-can-start-discussions')).toBeVisible();
  await screenshot.captureElement(
    'discussions/private_submissions/non_members_can_start_discussions',
    '.group-form',
    {
      height: 1400,
      spotlight: menuSpotlight('.group-form__non-members-can-start-discussions')
    }
  );
});

test('group_start_new', async ({ page, manual: screenshot }) => {
  await openGroup(page);
  await ensureSidebar(page);
  await expect(page.locator('.sidebar-start-group')).toBeVisible();
  await screenshot.capture('groups/starting_a_group/new_group', {
    spotlight: {
      selector: '.sidebar-start-group',
      padding: 6,
      radius: 6
    }
  });
});

test('group_start_form', async ({ page, manual: screenshot }) => {
  // In a narrow window the sidebar is an overlay that closes when the group
  // page updates its URL after loading. A wide window keeps it open.
  await page.setViewportSize({ width: 1440, height: 900 });
  await page.goto('/dev/setup_manual_oatmilk_group');
  await ensureSidebar(page);
  await page.locator('.sidebar-start-group').click();
  const form = page.locator('.group-form');
  await form.locator('.group-form__name input').fill('Oatmilk Producers Network');
  await expect(form.locator('.group-form__handle input')).toHaveValue('oatmilk-producers-network');
  await form.locator('.group-form__category-select .v-field').click();
  await page.locator('.v-overlay--active .group-form__category--self_managing').click();
  await editor(form.locator('.group-form__group-description')).fill('We coordinate shared purchasing, distribution, and training for regional oat milk producers.');
  await expect(form.locator('.group-form__name input')).toHaveValue('Oatmilk Producers Network');
  await screenshot.captureElement('groups/starting_a_group/new_group_start', '.group-form', { height: 1200 });
});

test('discussion_intro', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_discussion_intro');
  await expectLabel(page.locator('.context-panel__heading'), 'Improve the cafe bottle return process');
  // Wait for the comments to load; any one will do.
  await expect(page.locator('.topic-item__new-comment').first()).toBeVisible();
  await page.locator('.v-app-bar').evaluate(bar => { bar.style.visibility = 'hidden'; });
  await screenshot.captureRegion(
    'discussions/discussion-example',
    ['.topic-new-discussion', '.topic-item__new-comment', '.actions-panel'],
    { width: 1100, height: 1400, padding: 32, includeThreadGutters: true }
  );
});
