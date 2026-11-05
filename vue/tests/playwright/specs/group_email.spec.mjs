import { test, expect } from '../fixtures.mjs';

test('approving a held email assigns its sender and releases it', async ({ page }) => {
  await page.goto('/dev/setup_manual_oatmilk_unreleased_email')
  const pending = page.locator('.group-emails-panel')
  await expect(pending).toContainText('Returnable bottle collection proposal')

  await page.locator('.group-emails-panel__approve').click()
  const modal = page.locator('.member-email-alias-modal')
  await modal.locator('.member-email-alias-modal__search input').fill('Jamie')
  await modal.locator('.member-email-alias-modal__user', { hasText: 'Jamie Chen' }).click()
  await modal.locator('.member-email-alias-modal__confirm').click()
  await expect(modal).toBeHidden()
  await expect(pending).not.toContainText('Returnable bottle collection proposal')

  await page.reload()
  await expect(pending).toBeVisible()
  await expect(pending).not.toContainText('Returnable bottle collection proposal')
});
