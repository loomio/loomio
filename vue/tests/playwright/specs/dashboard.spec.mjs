import { test, expect } from '../fixtures.mjs';
import { blockMainContentRequests } from '../helpers/initialPage.mjs';

test('shows recent threads but not old ones', async ({ page }) => {
  const requests = await blockMainContentRequests(page);
  await page.route('**/api/v1/profile/groups?*', route => route.abort());
  await page.goto('/dev/setup_dashboard')
  const threads = page.locator('.dashboard-page__collections')
  await expect(threads).toContainText('Poll discussion')
  await expect(threads).toContainText('Recent discussion')
  await expect(threads).not.toContainText('Old discussion')
  await expect(page.locator('.polls-panel')).toBeVisible();
  expect(requests).toEqual([]);
});

test('marks a thread as read', async ({ page, flash }) => {
  await page.goto('/dev/setup_dashboard_with_one_thread')
  await page.locator('.action-dock__button--dismiss_thread').click()
  await expect(flash).toContainText('Discussion marked as read')
});

test('reuses bootstrapped pending polls across navigation and dashboard pages', async ({ page }) => {
  const pendingRequests = [];
  const stanceRequests = [];
  const groupRequests = [];
  const contentRequests = [];
  page.on('request', request => {
    const url = new URL(request.url());
    if (url.pathname === '/api/v1/polls' && url.searchParams.get('status') === 'vote') {
      pendingRequests.push(request.url());
    }
    if (url.pathname === '/api/v1/stances/my_stances') stanceRequests.push(request.url());
    if (url.pathname === '/api/v1/profile/groups') groupRequests.push(request.url());
    if (['/api/v1/topics', '/api/v1/topic_items', '/api/v1/polls'].includes(url.pathname)) contentRequests.push(url);
  });

  await page.goto('/dev/setup_dashboard');
  await expect(page.locator('.dashboard-page .poll-common-preview')).toBeVisible();
  await page.locator('.navbar__sidenav-toggle').click();
  await page.locator('.sidenav-left a[href="/dashboard/polls_to_vote_on"]').click();
  await expect(page.locator('.polls-to-vote-on-page .poll-common-preview')).toBeVisible();
  await page.setViewportSize({width: 600, height: 1000});
  await page.locator('.mobile-navigation a[href="/dashboard"]').click();
  await expect(page.locator('.dashboard-page .poll-common-preview')).toBeVisible();

  expect(pendingRequests).toEqual([]);
  expect(stanceRequests).toEqual([]);
  expect(groupRequests).toEqual([]);
  for (const url of contentRequests) {
    expect(url.searchParams.get('exclude_types').split(' ')).toContain('group');
  }
});
