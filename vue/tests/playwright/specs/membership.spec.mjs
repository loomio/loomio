import { test, expect } from '../fixtures.mjs';

test('shows_notification_history_for_an_accepted_member', async ({ lmo: page }) => {
  await page.loadPath('setup_membership_notification_history')
  await page.waitFor('.members-panel')
  await page.click('.members-panel .v-list-item:first-child .membership-dropdown__button')
  await page.waitFor('.membership-dropdown__notification-history .v-list-item-title')
  await page.expectText('.membership-dropdown__notification-history', 'Invitation delivery history')
  await page.click('.membership-dropdown__notification-history .v-list-item-title')
  await page.expectText('.membership-notification-history', 'Invitation resent')
  await page.expectText('.membership-notification-history .v-card-title', 'Invitation delivery history')
  await page.expectText('.membership-notification-history__blocked', 'Loomio has blocked email delivery to this address')
  await page.expectText('.membership-notification-history .v-card-subtitle', 'Emilio Estevez <emilio@example.com>')
  await page.expectCount('.membership-notification-history .v-expansion-panel', 7)
  await page.expectCount('.membership-notification-history [data-result="delivered"]', 1)
  await page.expectCount('.membership-notification-history [data-result="failed"]', 4)
  await page.expectNoElement('.membership-notification-history .v-expansion-panel-title[aria-expanded="true"]')
  await page.expectNoText('.membership-notification-history', 'Invitation history preview')
  await page.expectNoText('.membership-notification-history', '5.1.1 Recipient address does not exist')
  await page.expectText('.membership-notification-history', 'Delivery delay reported')

  const bounced = '.membership-notification-history .v-expansion-panel[data-email-status="bounced"]'
  await page.click(`${bounced} .v-expansion-panel-title`)
  await page.expectText(bounced, '5.1.1 Recipient address does not exist')
  await page.expectText(bounced, 'Invitation history preview: bounced')
  await page.first(`${bounced} .v-expansion-panel-title`).press('Enter')
  await page.expectAttribute(`${bounced} .v-expansion-panel-title`, 'aria-expanded', 'false', { exact: true });

  const delivered = '.membership-notification-history .v-expansion-panel[data-email-status="delivered"]'
  await page.first(`${delivered} .v-expansion-panel-title`).press('Enter')
  await page.expectText(delivered, 'Please join the wider group discussion')
  await page.expectText(delivered, "Accepted by recipient's mail server")
  await page.click('.membership-notification-history .v-expansion-panel:first-of-type .v-expansion-panel-title')
  await page.expectText('.membership-notification-history .v-expansion-panel:first-of-type', 'No custom message')
  await page.expectAttribute(`${delivered} .v-expansion-panel-title`, 'aria-expanded', 'false', { exact: true });
  await page.resizeWindow(390, 844)
  expect(await page.execute(() => {
    const card = document.querySelector('.membership-notification-history')
    return card.scrollWidth <= card.clientWidth
  }), 'History fits a narrow viewport').toBe(true)
  await page.click('.membership-notification-history .dismiss-modal-button')
  await page.expectNoElement('.membership-notification-history')
});

test('successfully_removes_a_group_member', async ({ lmo: page }) => {
  await page.loadPath('setup_group')
  await page.click('.group-page-members-tab')
  await page.pause(1000);
  await page.click('.members-panel .v-card .v-list .v-list-item:first-child .membership-dropdown')
  await page.click('.membership-dropdown__remove')
  await page.expectText('.confirm-modal', 'Remove member')
  await page.click('.confirm-modal__submit')
  await page.expectFlash('Member removed')
  await page.expectNoText('.members-panel', 'Emilio Estevez')
});

  // 'successfully_assigns_coordinator_privileges': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_group')
  //   page.click('.group-page-members-tab')
  //   page.click('.members-panel .v-card .v-list .v-list-item:first-child .membership-dropdown')
  //   page.click('.membership-dropdown__toggle-admin')
  //   page.expectFlash('Emilio Estevez is now an admin')
  // },

test('members_cannot_invite_members_by_default', async ({ lmo: page }) => {
  await page.loadPath('setup_group_as_member')
  await page.click('.group-page-members-tab')
  await page.expectNoElement('.membership-card__invite')
});

test('successfully_removes_a_member', async ({ lmo: page }) => {
  await page.loadPath('setup_group_with_multiple_coordinators')
  await page.click('.group-page-members-tab')
  await page.click('.members-panel .v-card .v-list .v-list-item:nth-child(1) .membership-dropdown')
  await page.click('.membership-dropdown__remove')
  await page.click('.confirm-modal__submit')
  await page.expectFlash('Member removed')
});

test('can_remove_coordinator_privileges', async ({ lmo: page }) => {
  await page.loadPath('setup_group_with_multiple_coordinators')

  await page.click('.group-page-members-tab')
  await page.pause(2000)
  await page.click('.members-panel .v-card .v-list .v-list-item:first-child .membership-dropdown')
  await page.click('.membership-dropdown__toggle-admin')
  await page.expectFlash('Emilio Estevez is no longer an admin')
});

  // breaks on travis, unknown why
  // 'can_self_promote_when_no_coordinators': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_group_with_no_coordinators')
  //   page.click('.group-page-members-tab')
  //   page.click('.members-panel .v-card .v-list .v-list-item:last-child .membership-dropdown', 500)
  //   page.click('.membership-dropdown__button', 500)
  //   page.click('.membership-dropdown__toggle-admin', 500)
  //   page.expectFlash('Patrick Swayze is now an admin')
  // },

  // 'can_self_promote_when_admin_of_parent_group': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_group_with_subgroups_as_admin')
  //   page.click('.group-page-members-tab')
  //   page.click('.members-panel .v-card .v-list .v-list-item:first-child .membership-dropdown')
  //   page.click('.membership-dropdown__toggle-admin')
  //   page.expectFlash('Jennifer Grey is now an admin')
  // },

test('cannot_self_promote_when_coordinators', async ({ lmo: page }) => {
  await page.loadPath('setup_group_as_member')
  await page.click('.group-page-members-tab')
  await page.click('.membership-dropdown')
  await page.expectNoText('.membership-dropdown', 'Make admin')
});

test('can_set_membership_title', async ({ lmo: page }) => {
  await page.loadPath('setup_group')
  await page.click('.group-page-members-tab')
  await page.click('.members-panel .v-card .v-list .v-list-item:last-child .membership-dropdown')
  await page.click('.membership-dropdown__set-title')
  await page.fillIn('.membership-form__title-input input', 'Suzerain')
  await page.click('.membership-form__submit')
  await page.expectFlash('Membership title updated')
});

test('can_edit_group_vote_weights', async ({ lmo: page }) => {
  await page.loadPath('setup_group_with_vote_weights')
  await page.click('.group-page-members-tab')
  await page.click('.members-panel__edit-weights')
  await page.waitFor('.member-weights-page .v-table tbody tr')
  await page.expectCount('.member-weights-page .v-table tbody tr', 3)
  await page.expectText('.member-weights-page .v-table tbody tr:first-child', 'Emilio')
  await page.expectText('.member-weights-page .v-table tbody tr:first-child', 'emilio@example.com')
  await page.expectText('.member-weights-page .v-table tbody tr:first-child', 'Treasurer')
  await page.expectText('.member-weights-page .v-table tbody tr:first-child', 'Delegate')
  await page.clearField('.member-weights-page .v-table tbody tr:first-child .member-weights-page__weight-input input')
  await page.fillIn('.member-weights-page .v-table tbody tr:first-child .member-weights-page__weight-input input', '2.5')
  await page.click('.member-weights-page__save')
  await page.expectFlash('Vote weights updated')

  await page.refreshAndWait()
  await page.waitFor('.member-weights-page .v-table tbody tr')
  await expect(page.first('.member-weights-page .v-table tbody tr:first-child .member-weights-page__weight-input input')).toHaveValue('2.5')

  await page.click('.member-weights-page__set-all')
  await page.waitFor('.member-weights-page__reset-dialog')
  await page.clearField('.member-weights-page__reset-weight input')
  await page.fillIn('.member-weights-page__reset-weight input', '0.75')
  await page.click('.member-weights-page__reset-save')
  await page.expectFlash('Vote weights updated')
  await page.refreshAndWait()
  await page.waitFor('.member-weights-page .v-table tbody tr')
  await expect(page.first('.member-weights-page .v-table tbody tr:first-child .member-weights-page__weight-input input')).toHaveValue('0.75')

  await page.fillIn('.member-weights-page__search input', 'emilio')
  await page.pause(1000)
  await page.expectCount('.member-weights-page .v-table tbody tr', 1)
  await page.expectText('.member-weights-page .v-table tbody tr:first-child', 'Emilio')
  await page.expectText('.member-weights-page__page-count', '1–1 of 1')
});

  // 'can_change_volume': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_group')
  //   page.click('.action-menu')
  //   page.click('.action-dock__button--change_volume')
  //   page.click('.volume-loud')
  //   page.click('.change-volume-form__submit')
  //   page.expectFlash('Notification settings updated')
  // }
