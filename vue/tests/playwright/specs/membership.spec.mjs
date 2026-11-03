import { test, expect } from '../fixtures.mjs';

test('shows_notification_history_for_an_accepted_member', async ({ page }) => {
  await page.goto('/dev/setup_membership_notification_history')
  await page.locator('.members-panel .v-list-item', { hasText: 'Emilio Estevez' }).locator('.membership-dropdown__button').click()
  await expect(page.locator('.membership-dropdown__notification-history .v-list-item-title')).toBeVisible()
  await expect(page.locator('.membership-dropdown__notification-history')).toContainText('Invitation delivery history')
  await page.locator('.membership-dropdown__notification-history .v-list-item-title').click()
  await expect(page.locator('.membership-notification-history')).toContainText('Invitation resent')
  await expect(page.locator('.membership-notification-history .v-card-title')).toContainText('Invitation delivery history')
  await expect(page.locator('.membership-notification-history__blocked')).toContainText('Loomio has blocked email delivery to this address')
  await expect(page.locator('.membership-notification-history .v-card-subtitle')).toContainText('Emilio Estevez <emilio@example.com>')
  await expect(page.locator('.membership-notification-history .v-expansion-panel')).toHaveCount(7)
  await expect(page.locator('.membership-notification-history [data-result="delivered"]')).toHaveCount(1)
  await expect(page.locator('.membership-notification-history [data-result="failed"]')).toHaveCount(4)
  await expect(page.locator('.membership-notification-history .v-expansion-panel-title[aria-expanded="true"]')).toHaveCount(0)
  await expect(page.locator('.membership-notification-history')).not.toContainText('Invitation history preview')
  await expect(page.locator('.membership-notification-history')).not.toContainText('5.1.1 Recipient address does not exist')
  await expect(page.locator('.membership-notification-history')).toContainText('Delivery delay reported')

  const bounced = '.membership-notification-history .v-expansion-panel[data-email-status="bounced"]'
  await page.locator(`${bounced} .v-expansion-panel-title`).click()
  await expect(page.locator(bounced)).toContainText('5.1.1 Recipient address does not exist')
  await expect(page.locator(bounced)).toContainText('Invitation history preview: bounced')
  await page.locator(`${bounced} .v-expansion-panel-title`).first().press('Enter')
  await expect(page.locator(`${bounced} .v-expansion-panel-title`)).toHaveAttribute('aria-expanded', 'false')

  const delivered = '.membership-notification-history .v-expansion-panel[data-email-status="delivered"]'
  await page.locator(`${delivered} .v-expansion-panel-title`).first().press('Enter')
  await expect(page.locator(delivered)).toContainText('Please join the wider group discussion')
  await expect(page.locator(delivered)).toContainText("Accepted by recipient's mail server")
  await page.locator('.membership-notification-history .v-expansion-panel:first-of-type .v-expansion-panel-title').click()
  await expect(page.locator('.membership-notification-history .v-expansion-panel:first-of-type')).toContainText('No custom message')
  await expect(page.locator(`${delivered} .v-expansion-panel-title`)).toHaveAttribute('aria-expanded', 'false')
  await page.setViewportSize({ width: 390, height: 844 })
  expect(await page.evaluate(() => {
    const card = document.querySelector('.membership-notification-history')
    return card.scrollWidth <= card.clientWidth
  }), 'History fits a narrow viewport').toBe(true)
  await page.locator('.membership-notification-history .dismiss-modal-button').click()
  await expect(page.locator('.membership-notification-history')).toHaveCount(0)
});

test('successfully_removes_a_group_member', async ({ page }) => {
  await page.goto('/dev/setup_group')
  await page.locator('.group-page-members-tab').click()
  await page.locator('.members-panel .v-card .v-list .v-list-item:first-child .membership-dropdown').click()
  await page.locator('.membership-dropdown__remove').click()
  await expect(page.locator('.confirm-modal')).toContainText('Remove member')
  await page.locator('.confirm-modal__submit').click()
  await expect(page.locator('.flash-root__message')).toContainText('Member removed')
  await expect(page.locator('.members-panel')).not.toContainText('Emilio Estevez')
});

test('members_cannot_invite_members_by_default', async ({ page }) => {
  await page.goto('/dev/setup_group_as_member')
  await page.locator('.group-page-members-tab').click()
  await expect(page.locator('.membership-card__invite')).toHaveCount(0)
});

test('successfully_removes_a_member', async ({ page }) => {
  await page.goto('/dev/setup_group_with_multiple_coordinators')
  await page.locator('.group-page-members-tab').click()
  await page.locator('.members-panel .v-card .v-list .v-list-item:nth-child(1) .membership-dropdown').click()
  await page.locator('.membership-dropdown__remove').click()
  await page.locator('.confirm-modal__submit').click()
  await expect(page.locator('.flash-root__message')).toContainText('Member removed')
});

test('can_remove_coordinator_privileges', async ({ page }) => {
  await page.goto('/dev/setup_group_with_multiple_coordinators')

  await page.locator('.group-page-members-tab').click()
  await page.locator('.members-panel .v-card .v-list .v-list-item:first-child .membership-dropdown').click()
  await page.locator('.membership-dropdown__toggle-admin').click()
  await expect(page.locator('.flash-root__message')).toContainText('Emilio Estevez is no longer an admin')
});

test('cannot_self_promote_when_coordinators', async ({ page }) => {
  await page.goto('/dev/setup_group_as_member')
  await page.locator('.group-page-members-tab').click()
  await page.locator('.membership-dropdown').click()
  await expect(page.locator('.membership-dropdown')).not.toContainText('Make admin')
});

test('can_set_membership_title', async ({ page }) => {
  await page.goto('/dev/setup_group')
  await page.locator('.group-page-members-tab').click()
  await page.locator('.members-panel .v-card .v-list .v-list-item:last-child .membership-dropdown').click()
  await page.locator('.membership-dropdown__set-title').click()
  await page.locator('.membership-form__title-input input').fill('Suzerain')
  await page.locator('.membership-form__submit').click()
  await expect(page.locator('.flash-root__message')).toContainText('Membership title updated')
});

test('can_edit_group_vote_weights', async ({ page }) => {
  await page.goto('/dev/setup_group_with_vote_weights')
  await page.locator('.group-page-members-tab').click()
  await page.locator('.members-panel__edit-weights').click()
  await expect(page.locator('.member-weights-page .v-table tbody tr')).toBeVisible()
  await expect(page.locator('.member-weights-page .v-table tbody tr')).toHaveCount(3)
  await expect(page.locator('.member-weights-page .v-table tbody tr:first-child')).toContainText('Emilio')
  await expect(page.locator('.member-weights-page .v-table tbody tr:first-child')).toContainText('emilio@example.com')
  await expect(page.locator('.member-weights-page .v-table tbody tr:first-child')).toContainText('Treasurer')
  await expect(page.locator('.member-weights-page .v-table tbody tr:first-child')).toContainText('Delegate')
  await page.locator('.member-weights-page .v-table tbody tr:first-child .member-weights-page__weight-input input').fill('2.5')
  await page.locator('.member-weights-page__save').click()
  await expect(page.locator('.flash-root__message')).toContainText('Vote weights updated')

  await page.reload()
  await expect(page.locator('.member-weights-page .v-table tbody tr')).toBeVisible()
  await expect(page.locator('.member-weights-page .v-table tbody tr:first-child .member-weights-page__weight-input input').first()).toHaveValue('2.5')

  await page.locator('.member-weights-page__set-all').click()
  await expect(page.locator('.member-weights-page__reset-dialog')).toBeVisible()
  await page.locator('.member-weights-page__reset-weight input').fill('0.75')
  await page.locator('.member-weights-page__reset-save').click()
  await expect(page.locator('.flash-root__message')).toContainText('Vote weights updated')
  await page.reload()
  await expect(page.locator('.member-weights-page .v-table tbody tr')).toBeVisible()
  await expect(page.locator('.member-weights-page .v-table tbody tr:first-child .member-weights-page__weight-input input').first()).toHaveValue('0.75')

  await page.locator('.member-weights-page__search input').fill('emilio')
  await expect(page.locator('.member-weights-page .v-table tbody tr')).toHaveCount(1)
  await expect(page.locator('.member-weights-page .v-table tbody tr:first-child')).toContainText('Emilio')
  await expect(page.locator('.member-weights-page__page-count')).toContainText('1–1 of 1')
});
