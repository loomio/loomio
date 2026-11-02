import { test, expect } from '../fixtures.mjs';

test('successfully_approves_a_membership_request', async ({ lmo: page }) => {
  await page.loadPath('setup_membership_requests')
  await page.click('.group-page-members-tab')
  await page.click('.group-page__requests-tab')
  await page.click('.membership-requests-page__approve', 500)
  await page.expectFlash('Membership request approved')
  await page.expectText('.membership-request__response', 'Approved by Patrick Swayze')
});

  // 'adds_existing_users_to_group_upon_approval': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_membership_requests')
  //   page.click('.group-page-members-tab')
  //   page.expectCount('.members-panel .v-list .v-list-item', 3)
  //   page.click('.group-page__requests-tab')
  //   page.click('.membership-requests-page__approve', 500)
  //   page.expectFlash('Membership request approved')
  //   page.click('.group-page-members-tab')
  //   page.expectCount('.members-panel .v-list .v-list-item', 4)
  // },

test('successfully_declines_a_membership_request', async ({ lmo: page }) => {
  await page.loadPath('setup_membership_requests')
  await page.click('.group-page-members-tab')
  await page.click('.group-page__requests-tab')
  await page.click('.membership-requests-page__decline', 500)
  await page.expectText('.membership-request__decline-help', 'Decline sends your reason to the applicant by email. They can submit a new request. Ignore closes the request without notifying them.')
  await expect(page.first('.membership-request__response-submit')).toBeDisabled()
  await page.expectElement('.membership-request__ignore')
  await page.fillIn('.membership-request__decline-reason-input textarea', 'Please answer the join prompt')
  await page.click('.membership-request__response-submit', 500)
  await page.expectFlash('Membership request declined')
  await page.expectText('.membership-request__response', 'Declined by Patrick Swayze')
  await page.expectText('.membership-request__decline-reason', 'Please answer the join prompt')
});

test('successfully_ignores_a_membership_request', async ({ lmo: page }) => {
  await page.loadPath('setup_membership_requests')
  await page.click('.group-page-members-tab')
  await page.click('.group-page__requests-tab')
  await page.click('.membership-requests-page__decline', 500)
  await page.click('.membership-request__ignore', 500)
  await page.expectFlash('Membership request ignored')
  await page.expectText('.membership-request__response', 'Declined by Patrick Swayze')
});
