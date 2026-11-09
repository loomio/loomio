import { test, expect } from '../fixtures.mjs';
import { box } from '../helpers/layout.mjs';
import { editor } from '../helpers/editor.mjs';

test.use({viewport: {width: 390, height: 844}});

test('opens cached threads while their refresh is pending', async ({page}) => {
  await page.goto('/dev/setup_dashboard');
  await expect(page.locator('.dashboard-page__collections')).toContainText('Recent discussion');
  await expect(page.locator('.dashboard-page__mobile-search')).toBeVisible();
  await expect(page.locator('.navbar__sidenav-toggle')).toHaveCount(0);
  await expect(page.locator('.navbar__search')).toHaveCount(0);
  await expect(page.locator('.mobile-navigation')).not.toContainText('Dashboard');
  expect((await box(page.locator('.mobile-navigation__dashboard'))).height).toBeGreaterThanOrEqual(48);

  await page.locator('.mobile-navigation__sidebar').click();
  await expect(page.locator('.sidebar__groups')).toBeVisible();
  await expect(page.locator('.mobile-navigation__sidebar')).toHaveAttribute('aria-expanded', 'true');
  // Dismiss the temporary drawer by tapping the page beside it.
  await page.mouse.click(382, 422);
  await expect(page.locator('.mobile-navigation__sidebar')).toHaveAttribute('aria-expanded', 'false');

  const pending = [];
  await page.route('**/api/v1/topic_items?*', route => { pending.push(route); });
  await page.locator('.topic-preview__link', {hasText: 'Recent discussion'}).click();
  await expect(page.locator('.topic-page__cached-context')).toContainText('Recent discussion');
  await expect(page.locator('.navbar__loading-slot .v-progress-circular')).toBeVisible();
  const navigation = await box(page.locator('.mobile-navigation'));
  const latest = await box(page.locator('.topic-page__latest'));
  expect(navigation.y - latest.bottom).toBeGreaterThanOrEqual(8);
  await page.locator('.mobile-navigation__contents').click();
  await expect(page.locator('.topic-sidebar')).toBeVisible();
  for (const route of pending) await route.abort();
});

test('keeps action tabs in view and retains the comment draft when switching forms', async ({page}) => {
  await page.goto('/dev/discussions/test_sampled_comments');
  const comment = editor(page.locator('.actions-panel'));
  await comment.fill('Keep this comment draft');
  await page.locator('.activity-panel__add-poll').click();
  await expect(page.locator('.poll-common-templates-list')).toBeVisible();

  async function expectTabsInView() {
    await expect.poll(async () => (await box(page.locator('.activity-panel__actions'))).y).toBeGreaterThanOrEqual(48);
    await expect.poll(async () => {
      const navigation = await box(page.locator('.mobile-navigation'));
      const tabs = await box(page.locator('.activity-panel__actions'));
      return navigation.y - tabs.bottom;
    }).toBeGreaterThan(100);
  }

  await expectTabsInView();
  await page.locator('.activity-panel__add-comment').click();
  await expect(comment).toContainText('Keep this comment draft');
  await expect(page.locator('.poll-common-templates-list')).toBeHidden();
  await expectTabsInView();
  const forms = await box(page.locator('.actions-panel__forms'));
  const commentPanel = await box(page.locator('.actions-panel__forms [role="tabpanel"]:visible'));
  expect(Math.abs(forms.height - commentPanel.height)).toBeLessThan(2);
});
