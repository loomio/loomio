import { test, expect } from '../fixtures.mjs';

test('successfully_approves_a_membership_request', async ({ page }) => {
  await page.goto('/dev/setup_membership_requests')
  await page.locator('.group-page-members-tab').click()
  await page.locator('.group-page__requests-tab').click()
  await page.locator('.membership-requests-page__approve').click()
  await expect(page.locator('.flash-root__message')).toContainText('Membership request approved')
  await expect(page.locator('.membership-request__response')).toContainText('Approved by Patrick Swayze')
});

test('successfully_declines_a_membership_request', async ({ page }) => {
  await page.goto('/dev/setup_membership_requests')
  await page.locator('.group-page-members-tab').click()
  await page.locator('.group-page__requests-tab').click()
  await page.locator('.membership-requests-page__decline').click()
  await expect(page.locator('.membership-request__decline-help')).toContainText('Decline sends your reason to the applicant by email. They can submit a new request. Ignore closes the request without notifying them.')
  await expect(page.locator('.membership-request__response-submit').first()).toBeDisabled()
  await expect(page.locator('.membership-request__ignore')).toBeVisible()
  await page.locator('.membership-request__decline-reason-input textarea').fill('Please answer the join prompt')
  await page.locator('.membership-request__response-submit').click()
  await expect(page.locator('.flash-root__message')).toContainText('Membership request declined')
  await expect(page.locator('.membership-request__response')).toContainText('Declined by Patrick Swayze')
  await expect(page.locator('.membership-request__decline-reason')).toContainText('Please answer the join prompt')
});

test('successfully_ignores_a_membership_request', async ({ page }) => {
  await page.goto('/dev/setup_membership_requests')
  await page.locator('.group-page-members-tab').click()
  await page.locator('.group-page__requests-tab').click()
  await page.locator('.membership-requests-page__decline').click()
  await page.locator('.membership-request__ignore').click()
  await expect(page.locator('.flash-root__message')).toContainText('Membership request ignored')
  await expect(page.locator('.membership-request__response')).toContainText('Declined by Patrick Swayze')
});
