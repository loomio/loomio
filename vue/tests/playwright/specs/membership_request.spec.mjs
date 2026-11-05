import { test, expect } from '../fixtures.mjs';

test.describe('responding to membership requests', () => {
  // The scenario has three pending requests from random people. Pin the first
  // by its name, because a request moves down the list once answered.
  let request;

  test.beforeEach(async ({ page }) => {
    await page.goto('/dev/setup_membership_requests');
    await page.locator('.group-page-members-tab').click();
    await page.locator('.group-page__requests-tab').click();
    const name = await page.locator('.membership-request__name').first().innerText();
    request = page.locator('.membership-requests', { hasText: name.split(' <')[0] });
  });

  test('approves a request', async ({ page, flash }) => {
    await request.locator('.membership-requests-page__approve').click();
    await expect(flash).toContainText('Membership request approved');
    await expect(request.locator('.membership-request__response')).toContainText('Approved by Patrick Swayze');
  });

  test('declines a request with a reason', async ({ page, flash }) => {
    await request.locator('.membership-requests-page__decline').click();
    await expect(page.locator('.membership-request__decline-help')).toContainText('Decline sends your reason to the applicant by email. They can submit a new request. Ignore closes the request without notifying them.');
    const submit = page.locator('.membership-request__response-submit');
    await expect(submit).toBeDisabled();
    await page.locator('.membership-request__decline-reason-input textarea').fill('Please answer the join prompt');
    await submit.click();
    await expect(flash).toContainText('Membership request declined');
    await expect(request.locator('.membership-request__response')).toContainText('Declined by Patrick Swayze');
    await expect(request.locator('.membership-request__decline-reason')).toContainText('Please answer the join prompt');
  });

  test('ignores a request', async ({ page, flash }) => {
    await request.locator('.membership-requests-page__decline').click();
    await page.locator('.membership-request__ignore').click();
    await expect(flash).toContainText('Membership request ignored');
    await expect(request.locator('.membership-request__response')).toContainText('Declined by Patrick Swayze');
  });
});
