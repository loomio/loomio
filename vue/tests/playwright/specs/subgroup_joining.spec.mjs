import { test, expect } from '../fixtures.mjs';
import { groupAction, ensureSidebar } from '../helpers/groups.mjs';
import { choose } from '../helpers/vuetify.mjs';

const privacy = (page, option) => page.locator(`.group-form__privacy-${option}`);
const joining = (page, option) => page.locator(`.group-form__membership-granted-upon-${option}`);
const helpLink = page => page.locator('.group-form__guide-link');
const submit = page => page.locator('.group-form__submit-button');

async function startSubgroup(page, scenario) {
  await page.goto(`/dev/${scenario}`);
  await ensureSidebar(page);
  await page.locator('.sidebar-start-subgroup').click();
}

async function editGroup(page, tab) {
  await groupAction(page, 'edit_group');
  await page.locator(`.group-form__${tab}-tab`).click();
}

test.describe('starting a subgroup', () => {
  test('switching to a secret parent resets a public privacy choice', async ({ page, flash }) => {
    await startSubgroup(page, 'setup_subgroup_privacy_parent_switching');
    await privacy(page, 'open').locator('input').check();
    await choose(page, '.group-form__parent-group', 'Secret planning group');
    await expect(privacy(page, 'open')).toHaveCount(0);
    await expect(privacy(page, 'closed')).toHaveCount(0);
    await expect(privacy(page, 'parent_members').locator('input')).toBeChecked();
    await joining(page, 'request').locator('input').check();
    await page.locator('.group-form__name input').fill('Internal work');
    await expect(page.locator('.group-form__handle input')).toHaveValue('secret-planning-internal-work');
    await submit(page).click();
    await expect(flash).toContainText('Group started');
  });

  test('a private parent offers parent-member visibility, but not open or closed', async ({ page, flash }) => {
    await startSubgroup(page, 'setup_secret_group');
    await page.locator('.group-form__name input').fill('Internal volunteers');
    await expect(page.locator('.group-form__handle input')).toHaveValue('secret-shoes-internal-volunteers');
    await expect(privacy(page, 'open')).toHaveCount(0);
    await expect(privacy(page, 'closed')).toHaveCount(0);
    await privacy(page, 'parent_members').locator('input').check();
    await joining(page, 'request').locator('input').check();
    await submit(page).click();
    await expect(flash).toContainText('Group started');

    await editGroup(page, 'privacy');
    await expect(privacy(page, 'parent_members').locator('input')).toBeChecked();
    await expect(privacy(page, 'open')).toHaveCount(0);
    await expect(privacy(page, 'closed')).toHaveCount(0);
  });

  test('sets parent-member visibility and joining without approval, then edits them', async ({ page, flash }) => {
    await startSubgroup(page, 'setup_closed_group');
    await page.locator('.group-form__name input').fill('Volunteer subgroup');
    await privacy(page, 'secret').locator('input').check();
    await expect(joining(page, 'request')).toHaveCount(0);
    await privacy(page, 'parent_members').locator('input').check();
    await expect(joining(page, 'request')).toContainText('Join without approval');
    await joining(page, 'request').locator('input').check();
    await submit(page).click();
    await expect(flash).toContainText('Group started');

    // Each tab of the form links to its page of the manual.
    await groupAction(page, 'edit_group');
    await expect(helpLink(page)).toHaveAttribute('href', /\/user_manual\/groups\/settings\/profile/);
    await page.locator('.group-form__privacy-tab').click();
    await expect(helpLink(page)).toHaveAttribute('href', /\/user_manual\/groups\/settings\/privacy/);
    await expect(privacy(page, 'parent_members').locator('input')).toBeChecked();
    await expect(joining(page, 'request').locator('input')).toBeChecked();
    await joining(page, 'approval').locator('input').check();
    await submit(page).click();
    await expect(flash).toContainText('Group updated');

    await editGroup(page, 'privacy');
    await expect(joining(page, 'approval').locator('input')).toBeChecked();
    await joining(page, 'request').locator('input').check();
    await page.locator('.group-form__permissions-tab').click();
    await expect(helpLink(page)).toHaveAttribute('href', /\/user_manual\/groups\/settings\/permissions/);
    await page.locator('.group-form__parent-members-can-see-discussions input').check();
    await submit(page).click();
    await expect(flash).toContainText('Group updated');

    await editGroup(page, 'privacy');
    await expect(privacy(page, 'parent_members').locator('input')).toBeChecked();
    await expect(joining(page, 'request').locator('input')).toBeChecked();
    await page.locator('.group-form__permissions-tab').click();
    await expect(page.locator('.group-form__parent-members-can-see-discussions input')).toBeChecked();
  });
});

test.describe('joining a subgroup', () => {
  test('a parent member joins, leaves and rejoins', async ({ page, flash }) => {
    await page.goto('/dev/setup_subgroup_parent_member_joining');
    await page.locator('.join-group-button').click();
    await expect(flash).toContainText('You are now a member');
    await expect(page.locator('.membership-request-form')).toHaveCount(0);
    await groupAction(page, 'leave_group');
    await expect(page.locator('.action-dock__button--edit_group')).toHaveCount(0);
    await page.locator('.confirm-modal__submit').click();
    await expect(flash).toContainText('You have left');
    await expect(page.locator('.group-page__name')).toContainText('Dirty Dancing Shoes');
    await page.goBack();
    await page.locator('.join-group-button').click();
    await expect(flash).toContainText('You are now a member');
  });

  test('a pending request does not stop an eligible parent member joining', async ({ page, flash }) => {
    await page.goto('/dev/setup_subgroup_parent_member_joining_with_pending_request');
    await page.locator('.join-group-button').click();
    await expect(flash).toContainText('You are now a member');
  });

  test('an outsider cannot see the subgroup', async ({ page }) => {
    await page.goto('/dev/setup_subgroup_parent_member_joining_as_outsider');
    await expect(page.locator('.error-page__forbidden')).toBeVisible();
    await expect(page.locator('.join-group-button')).toHaveCount(0);
  });

  test('an outsider joins a public subgroup that allows joining without approval', async ({ page, flash }) => {
    await page.goto('/dev/setup_public_subgroup_immediate_joining_as_outsider');
    await expect(page.locator('.group-page__name')).toContainText('Volunteer subgroup');
    await page.locator('.join-group-button').click();
    await expect(flash).toContainText('You are now a member');
  });
});
