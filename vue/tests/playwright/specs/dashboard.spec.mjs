import { test, expect } from '../fixtures.mjs';

test('displays_a_view_of_recent_threads', async ({ lmo: page }) => {
  await page.loadPath('setup_dashboard')
  await page.expectText('.dashboard-page__collections', 'Poll discussion')
  await page.expectText('.dashboard-page__collections', 'Recent discussion')
  await page.expectNoText('.dashboard-page__collections', 'Old discussion')
});

test('dismisses_a_thread', async ({ lmo: page }) => {
  await page.loadPath('setup_dashboard_with_one_thread')
  // page.ensureSidebar()
  // page.click('.sidebar__list-item-button--recent')
  await page.expectElement('.topic-previews-container')
  await page.click('.action-dock__button--dismiss_thread')
  // page.expectText('.confirm-modal h1', 'Dismiss thread')
  // page.click('.confirm-modal__submit')
  await page.expectFlash('Discussion marked as read')
});

