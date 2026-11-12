import { test, expect } from '../fixtures.mjs';
import { box } from '../helpers/layout.mjs';

const readParent = page => page.locator('.new-comment', {hasText: 'Long read parent'});

for (const width of [390, 1000]) {
  test(`shows full read and unread contributions at ${width}px`, async ({page}) => {
    await page.setViewportSize({width, height: 844});
    await page.goto('/dev/discussions/test_long_content');
    const context = page.locator('.context-panel__description');
    const parent = readParent(page);
    const details = parent.locator('.new-comment__body a');
    await expect(context.locator('p')).toHaveCount(13);
    expect((await box(context)).height).toBeGreaterThan(320);
    await details.scrollIntoViewIfNeeded();
    await expect(details).toBeInViewport();
    await expect(page.locator('.body-preview__show-more')).toHaveCount(0);
    const body = await box(parent.locator('.new-comment__body'));
    const link = await box(details);
    expect(body.bottom).toBeGreaterThanOrEqual(link.bottom);
    const unread = page.locator('.new-comment', {hasText: 'Long unread comment'});
    await expect(unread.locator('.new-comment__body p')).toHaveCount(13);
    expect((await box(unread.locator('.new-comment__body'))).height).toBeGreaterThan(320);
    await expect(page.locator('.new-comment', {hasText: 'Unread reply:'})).toBeVisible();
  });
}

test('opens a direct comment link with its full content accessible', async ({page}) => {
  await page.goto('/dev/discussions/test_long_content?focus=parent');
  const parent = readParent(page);
  const details = parent.locator('.new-comment__body a');
  await expect(parent.locator('.new-comment__body p')).toHaveCount(14);
  await details.focus();
  await expect(details).toBeFocused();
  await expect(details).toBeInViewport();
  await expect(parent.locator('.body-preview__show-more')).toHaveCount(0);
});
