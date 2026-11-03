import { test, expect } from '../fixtures.mjs';
import { member, memberAction, openMembers } from '../helpers/members.mjs';

test('shows the invitation history of an accepted member', async ({ page }) => {
  await page.goto('/dev/setup_membership_notification_history');
  await memberAction(page, 'Emilio Estevez', 'notification-history');

  const history = page.locator('.membership-notification-history');
  const entries = history.locator('.membership-notification-history__item');
  const entry = status => history.locator(`.membership-notification-history__item[data-email-status="${status}"]`);
  const toggle = item => item.locator('.v-expansion-panel-title');
  await expect(history.locator('.v-card-title')).toContainText('Invitation delivery history');
  await expect(history.locator('.v-card-subtitle')).toContainText('Emilio Estevez <emilio@example.com>');
  await expect(history.locator('.membership-notification-history__blocked')).toContainText('Loomio has blocked email delivery to this address');
  await expect(history).toContainText('Invitation resent');
  await expect(history).toContainText('Delivery delay reported');
  await expect(entries).toHaveCount(7);
  await expect(history.locator('[data-result="delivered"]')).toHaveCount(1);
  await expect(history.locator('[data-result="failed"]')).toHaveCount(4);

  // Entries start collapsed, and open one at a time.
  await expect(history.locator('.v-expansion-panel-title[aria-expanded="true"]')).toHaveCount(0);
  await expect(history).not.toContainText('5.1.1 Recipient address does not exist');
  await toggle(entry('bounced')).click();
  await expect(entry('bounced')).toContainText('5.1.1 Recipient address does not exist');
  await expect(entry('bounced')).toContainText('Invitation history preview: bounced');
  await toggle(entry('bounced')).press('Enter');
  await expect(toggle(entry('bounced'))).toHaveAttribute('aria-expanded', 'false');
  await toggle(entry('delivered')).press('Enter');
  await expect(entry('delivered')).toContainText('Please join the wider group discussion');
  await expect(entry('delivered')).toContainText("Accepted by recipient's mail server");
  // The newest entry is a resend without a message.
  await toggle(entries.first()).click();
  await expect(entries.first()).toContainText('No custom message');
  await expect(toggle(entry('delivered'))).toHaveAttribute('aria-expanded', 'false');

  await page.setViewportSize({ width: 390, height: 844 });
  const overflow = await history.evaluate(card => card.scrollWidth - card.clientWidth);
  expect(overflow, 'the history fits a phone screen').toBeLessThanOrEqual(0);
  await history.locator('.dismiss-modal-button').click();
  await expect(history).toHaveCount(0);
});

test.describe('as a group admin', () => {
  test('removes a member', async ({ page, flash }) => {
    await page.goto('/dev/setup_group');
    await openMembers(page);
    await memberAction(page, 'Emilio Estevez', 'remove');
    await expect(page.locator('.confirm-modal')).toContainText('Remove member');
    await page.locator('.confirm-modal__submit').click();
    await expect(flash).toContainText('Member removed');
    await expect(member(page, 'Emilio Estevez')).toHaveCount(0);
  });

  test('sets a member\'s title', async ({ page, flash }) => {
    await page.goto('/dev/setup_group');
    await openMembers(page);
    await memberAction(page, 'Emilio Estevez', 'set-title');
    await page.locator('.membership-form__title-input input').fill('Suzerain');
    await page.locator('.membership-form__submit').click();
    await expect(flash).toContainText('Membership title updated');
    await expect(member(page, 'Emilio Estevez')).toContainText('Suzerain');
  });

  test('removes another admin\'s admin role', async ({ page, flash }) => {
    await page.goto('/dev/setup_group_with_multiple_coordinators');
    await openMembers(page);
    await memberAction(page, 'Emilio Estevez', 'toggle-admin');
    await expect(flash).toContainText('Emilio Estevez is no longer an admin');
  });

  test('edits vote weights', async ({ page, flash }) => {
    await page.goto('/dev/setup_group_with_vote_weights');
    await openMembers(page);
    await page.locator('.members-panel__edit-weights').click();
    const rows = page.locator('.member-weights-page__member');
    const emilio = rows.filter({ hasText: 'emilio@example.com' });
    const weight = emilio.locator('.member-weights-page__weight-input input');
    await expect(rows).toHaveCount(3);
    for (const text of ['Emilio', 'Treasurer', 'Delegate']) { await expect(emilio).toContainText(text); }

    await weight.fill('2.5');
    await page.locator('.member-weights-page__save').click();
    await expect(flash).toContainText('Vote weights updated');
    await page.reload();
    await expect(weight).toHaveValue('2.5');

    await page.locator('.member-weights-page__set-all').click();
    await page.locator('.member-weights-page__reset-weight input').fill('0.75');
    await page.locator('.member-weights-page__reset-save').click();
    await expect(flash).toContainText('Vote weights updated');
    await page.reload();
    await expect(weight).toHaveValue('0.75');

    await page.locator('.member-weights-page__search input').fill('emilio');
    await expect(rows).toHaveCount(1);
    await expect(emilio).toBeVisible();
    await expect(page.locator('.member-weights-page__page-count')).toContainText('1–1 of 1');
  });
});

test.describe('as a member', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/dev/setup_group_as_member');
    await openMembers(page);
  });

  test('cannot invite people by default', async ({ page }) => {
    await expect(member(page, 'Jennifer Grey')).toBeVisible();
    await expect(page.locator('.membership-card__invite')).toHaveCount(0);
  });

  test('cannot make themselves an admin', async ({ page }) => {
    await member(page, 'Jennifer Grey').locator('.membership-dropdown__button').click();
    await expect(page.locator('.v-overlay--active .v-list')).toBeVisible();
    await expect(page.locator('.v-overlay--active .membership-dropdown__toggle-admin')).toHaveCount(0);
  });
});
