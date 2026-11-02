import { test, expect } from '../fixtures.mjs';

test('switching to a secret parent resets a public subgroup privacy selection', async ({ page }) => {
  await page.goto('/dev/setup_subgroup_privacy_parent_switching')
  await page.click('.navbar__sidenav-toggle')
  await page.click('.sidebar-start-subgroup')
  await page.click('.group-form__privacy-open')
  await expect(page.locator('.group-form__privacy-open input')).toBeChecked()
  await page.click('.group-form__parent-group .v-field')
  await expect(page.locator('.v-overlay--active .v-select__content')).toBeVisible()
  await page.locator('.v-overlay--active .v-list-item', { hasText: 'Secret planning group' }).first().click()
  await expect(page.locator('.group-form__privacy-open')).toHaveCount(0)
  await expect(page.locator('.group-form__privacy-closed')).toHaveCount(0)
  await expect(page.locator('.group-form__privacy-parent_members input')).toBeChecked()
  await page.click('.group-form__membership-granted-upon-request label')
  await page.fill('#group-name', 'Internal work')
  await expect(page.locator('.group-form__handle input')).toHaveValue('secret-planning-internal-work')
  await page.click('.group-form__submit-button')
  await expect(page.locator('.flash-root__message')).toContainText('Group started')
});

test('configure parent visibility and immediate joining when creating and editing a subgroup', async ({ page }) => {
  await page.goto('/dev/setup_closed_group')
  await page.click('.navbar__sidenav-toggle')
  await page.click('.sidebar-start-subgroup')
  await page.fill('#group-name', 'Volunteer subgroup')
  await page.click('.group-form__privacy-secret')
  await expect(page.locator('.group-form__membership-granted-upon-request')).toHaveCount(0)
  await page.click('.group-form__privacy-parent_members')
  await expect(page.locator('.group-form__membership-granted-upon-request')).toContainText('Join without approval')
  await page.click('.group-form__membership-granted-upon-request label')
  await expect(page.locator('.group-form__membership-granted-upon-request input')).toBeChecked()
  await page.click('.group-form__submit-button')
  await expect(page.locator('.flash-root__message')).toContainText('Group started')

  await page.click('.action-menu')
  await page.click('.action-dock__button--edit_group')
  await expect(page.locator('.group-form__guide-link')).toContainText('Help')
  await expect(page.locator('.group-form__guide-link')).toHaveAttribute('href', /\/user_manual\/groups\/settings\/profile/)
  await page.click('.group-form__privacy-tab')
  await expect(page.locator('.group-form__guide-link')).toContainText('Help')
  await expect(page.locator('.group-form__guide-link')).toHaveAttribute('href', /\/user_manual\/groups\/settings\/privacy/)
  await expect(page.locator('.group-form__privacy-parent_members input')).toBeChecked()
  await expect(page.locator('.group-form__membership-granted-upon-request')).toContainText('Join without approval')
  await expect(page.locator('.group-form__membership-granted-upon-request input')).toBeChecked()
  await page.click('.group-form__membership-granted-upon-approval label')
  await page.click('.group-form__submit-button')
  await expect(page.locator('.flash-root__message')).toContainText('Group updated')

  await page.click('.action-menu')
  await page.click('.action-dock__button--edit_group')
  await page.click('.group-form__privacy-tab')
  await expect(page.locator('.group-form__membership-granted-upon-approval input')).toBeChecked()
  await page.click('.group-form__membership-granted-upon-request label')
  await page.click('.group-form__permissions-tab')
  await expect(page.locator('.group-form__guide-link')).toContainText('Help')
  await expect(page.locator('.group-form__guide-link')).toHaveAttribute('href', /\/user_manual\/groups\/settings\/permissions/)
  await page.click('.group-form__parent-members-can-see-discussions')
  await page.click('.group-form__submit-button')
  await expect(page.locator('.flash-root__message')).toContainText('Group updated')

  await page.click('.action-menu')
  await page.click('.action-dock__button--edit_group')
  await page.click('.group-form__privacy-tab')
  await expect(page.locator('.group-form__privacy-parent_members input')).toBeChecked()
  await expect(page.locator('.group-form__membership-granted-upon-request input')).toBeChecked()
  await page.click('.group-form__permissions-tab')
  await expect(page.locator('.group-form__parent-members-can-see-discussions input')).toBeChecked()
});

test('a private parent offers parent visibility and secret subgroup privacy', async ({ page }) => {
  await page.goto('/dev/setup_secret_group')
  await page.click('.navbar__sidenav-toggle')
  await page.click('.sidebar-start-subgroup')
  await page.fill('#group-name', 'Internal volunteers')
  await expect(page.locator('.group-form__handle input')).toHaveValue('secret-shoes-internal-volunteers')
  await expect(page.locator('.group-form__privacy-open')).toHaveCount(0)
  await expect(page.locator('.group-form__privacy-closed')).toHaveCount(0)
  await page.click('.group-form__privacy-parent_members')
  await page.click('.group-form__membership-granted-upon-request label')
  await page.click('.group-form__submit-button')
  await expect(page.locator('.flash-root__message')).toContainText('Group started')
  await page.click('.action-menu')
  await page.click('.action-dock__button--edit_group')
  await page.click('.group-form__privacy-tab')
  await expect(page.locator('.group-form__privacy-parent_members input')).toBeChecked()
  await expect(page.locator('.group-form__privacy-open')).toHaveCount(0)
  await expect(page.locator('.group-form__privacy-closed')).toHaveCount(0)
});

test('ordinary parent members can join leave and rejoin a parent visible subgroup', async ({ page }) => {
  await page.goto('/dev/setup_subgroup_parent_member_joining')
  await page.click('.join-group-button')
  await expect(page.locator('.flash-root__message')).toContainText('You are now a member')
  await expect(page.locator('.membership-request-form')).toHaveCount(0)
  await page.click('.action-menu')
  await expect(page.locator('.action-dock__button--edit_group')).toHaveCount(0)
  await page.click('.action-dock__button--leave_group')
  await page.click('.confirm-modal__submit')
  await expect(page.locator('.flash-root__message')).toContainText('You have left')
  await page.goBack();
  await page.click('.join-group-button')
  await expect(page.locator('.flash-root__message')).toContainText('You are now a member')
});

test('outsiders cannot self join through the subgroup page', async ({ page }) => {
  await page.goto('/dev/setup_subgroup_parent_member_joining_as_outsider')
  await expect(page.locator('.error-page__forbidden')).toBeVisible()
  await expect(page.locator('.join-group-button')).toHaveCount(0)
});

test('outsiders can join a publicly visible subgroup with immediate joining', async ({ page }) => {
  await page.goto('/dev/setup_public_subgroup_immediate_joining_as_outsider')
  await expect(page.locator('.group-page__name')).toContainText('Volunteer subgroup')
  await page.click('.join-group-button')
  await expect(page.locator('.flash-root__message')).toContainText('You are now a member')
});

test('a pending approval request does not prevent an eligible parent member joining', async ({ page }) => {
  await page.goto('/dev/setup_subgroup_parent_member_joining_with_pending_request')
  await page.click('.join-group-button')
  await expect(page.locator('.flash-root__message')).toContainText('You are now a member')
});
