import { test, expect } from '../fixtures.mjs';
import { box } from '../helpers/layout.mjs';

const readParent = page => page.locator('.new-comment', {hasText: 'Long read parent'});
const unreadComment = page => page.locator('.new-comment', {hasText: 'Long unread comment'});

for (const width of [390, 1000]) {
  for (const target of ['context', 'parent']) {
    for (const action of ['button', 'text']) {
      test(`keeps the top of the viewport fixed when showing more ${target} via ${action} at ${width}px`, async ({page}) => {
        await page.setViewportSize({width, height: 844});
        await page.goto('/dev/discussions/test_body_previews');
        const body = target === 'context' ? page.locator('.context-panel .body-preview') : readParent(page).locator('.body-preview');
        const button = body.locator('.body-preview__show-more');
        await button.scrollIntoViewIfNeeded();
        // Cover a partly scrolled preview and one whose beginning is visible.
        const top = action === 'text' ? 120 : -120;
        await page.mouse.wheel(0, (await box(body)).y - top);
        await expect.poll(async () => (await box(body)).y).toBeCloseTo(top, 0);
        const before = await box(body);
        if (action === 'button') {
          await button.click();
        } else {
          const preview = await box(body.locator('.body-preview__viewport'));
          await page.mouse.click(preview.x + 30, preview.y + 100);
        }
        await expect(button).toHaveCount(0);
        await expect.poll(async () => (await box(body)).y).toBeCloseTo(before.y, 0);
        await expect(body.locator('.body-preview__content')).toBeFocused();
      });
    }
  }
}

for (const announcement of ['note', 'notify', 'both']) {
  test(`shows context announced with ${announcement} fully while keeping read parents folded`, async ({page}) => {
    await page.goto(`/dev/discussions/test_body_previews?context_edited=${announcement}`);
    const context = page.locator('.context-panel .body-preview');
    await expect(context).toContainText('Updated read context');
    await expect(context).not.toHaveClass(/body-preview--folded/);
    await expect(context.locator('.body-preview__show-more')).toHaveCount(0);
    expect((await box(context)).height).toBeGreaterThan(320);
    await expect(readParent(page).locator('.body-preview')).toHaveClass(/body-preview--folded/);
  });
}
test('keeps a quiet context edit eligible for a preview', async ({page}) => {
  await page.goto('/dev/discussions/test_body_previews?context_edited=quiet');
  await expect(page.locator('.context-panel .body-preview')).toHaveClass(/body-preview--folded/);
});

for (const width of [390, 1000]) {
  test(`previews long read parents and keeps unread bodies expanded at ${width}px`, async ({page}) => {
    await page.setViewportSize({width, height: 844});
    await page.goto('/dev/discussions/test_body_previews');
    const context = page.locator('.context-panel .body-preview');
    const parent = readParent(page).locator('.body-preview');
    await expect(context).toHaveClass(/body-preview--folded/);
    await expect(parent).toHaveClass(/body-preview--folded/);
    const previewHeight = (await box(parent.locator('.body-preview__viewport'))).height;
    expect(previewHeight).toBeLessThan((await box(parent.locator('.body-preview__content'))).height);
    await expect(parent.locator('.body-preview__show-more')).toHaveCount(1);
    await expect(page.locator('.new-comment', {hasText: 'Short read comment'}).locator('.body-preview__show-more')).toHaveCount(0);
    const moderate = page.locator('.new-comment', {hasText: 'Moderately long read comment'}).locator('.body-preview');
    expect((await box(moderate)).height).toBeGreaterThan(previewHeight);
    expect((await box(moderate)).height).toBeLessThan(previewHeight * 1.5);
    await expect(moderate.locator('.body-preview__show-more')).toHaveCount(0);
    const unread = unreadComment(page).locator('.body-preview');
    await expect(unread).not.toHaveClass(/body-preview--folded/);
    await expect(unread.locator('.body-preview__show-more')).toHaveCount(0);
    expect((await box(unread)).height).toBeGreaterThan(320);
    await expect(page.locator('.new-comment', {hasText: 'Unread reply:'})).toBeVisible();
  });
}

test('expands a parent for the visit without offering a reverse control', async ({page}) => {
  await page.setViewportSize({width: 390, height: 844});
  await page.goto('/dev/discussions/test_body_previews');
  const parent = readParent(page).locator('.body-preview');
  const toggle = parent.locator('.body-preview__show-more');
  await toggle.click();
  await expect(toggle).toHaveCount(0);
  await expect(parent.locator('.body-preview__content')).toBeFocused();
  expect((await box(parent)).height).toBeGreaterThan(320);
  await page.setViewportSize({width: 1000, height: 844});
  await expect(parent).not.toHaveClass(/body-preview--folded/);
  await expect(toggle).toHaveCount(0);
});

test('opens a directly linked read comment fully expanded', async ({page}) => {
  await page.goto('/dev/discussions/test_body_previews?focus=parent');
  const parent = readParent(page).locator('.body-preview');
  await expect(parent).not.toHaveClass(/body-preview--folded/);
  await expect(parent.locator('.body-preview__show-more')).toHaveCount(0);
  expect((await box(parent)).height).toBeGreaterThan(320);
});

test('keyboard navigation reveals links in a folded parent', async ({page}) => {
  await page.goto('/dev/discussions/test_body_previews');
  const parent = readParent(page).locator('.body-preview');
  const toggle = parent.locator('.body-preview__show-more');
  await toggle.focus();
  await page.keyboard.press('Shift+Tab');
  await expect(parent).not.toHaveClass(/body-preview--folded/);
  await expect(parent.locator('.new-comment__body a')).toBeFocused();
});

test('browser find reveals a match in clipped text', async ({page}) => {
  await page.goto('/dev/discussions/test_body_previews');
  const parent = readParent(page).locator('.body-preview');
  await expect(parent).toHaveClass(/body-preview--folded/);
  // Native browser find has no Playwright locator API.
  const found = await page.evaluate(() => window.find('Delivery details'));
  expect(found).toBe(true);
  await expect(parent).not.toHaveClass(/body-preview--folded/);
  await expect(parent.locator('.new-comment__body a')).toBeInViewport();
});
