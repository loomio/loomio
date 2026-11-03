import { test, expect } from '../fixtures.mjs';

const joinButton = page => page.locator('.join-group-button');

async function requestToJoin(page, introduction) {
  await joinButton(page).click();
  await page.locator('.membership-request-form__introduction textarea').fill(introduction);
  await page.locator('.membership-request-form__submit-btn').click();
}

test.describe('a closed group to a visitor', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/dev/setup_closed_group_to_join');
  });

  test('shows its public content', async ({ page }) => {
    await expect(page.locator('.group-page__description')).toContainText('An FBI agent goes undercover');
    await expect(page.locator('.topic-previews')).toContainText("The name's Johnny Utah!");
  });

  test('hides its private content', async ({ page }) => {
    await expect(page.locator('.discussions-panel__new-topic-button')).toHaveCount(0);
    await page.locator('.group-page-members-tab').click();
    await expect(page.locator('.members-panel')).toContainText('You do not have permission to do this.');
  });

  test('takes a membership request', async ({ page, flash }) => {
    await requestToJoin(page, 'Hello I am a bot and id like to advertise junk to your fine membership');
    await expect(flash).toContainText('You have requested to join');
    await expect(joinButton(page)).toContainText('Membership requested');
    await expect(joinButton(page)).toBeDisabled();
  });
});

test('joining a group that admits on request adds you at once', async ({ page, flash }) => {
  await page.goto('/dev/setup_public_group_to_join_upon_request');
  await joinButton(page).click();
  await expect(flash).toContainText('You are now a member of');
  await page.locator('.group-page-members-tab').click();
  await expect(page.locator('.members-panel')).toContainText('Jennifer');
});

test('a declined request shows the reason and allows another request', async ({ page, flash }) => {
  await page.goto('/dev/setup_manual_oatmilk_declined_membership_request');
  await expect(page.locator('.group-page')).toContainText('Your request to join was declined: Please tell us which cafe you work with and how you would like to contribute.');
  await expect(joinButton(page)).toContainText('Ask to join again');
  await requestToJoin(page, 'I work with Harbour Cafe and can help coordinate Tuesday bottle collections.');
  await expect(flash).toContainText('You have requested to join');
  await expect(joinButton(page)).toContainText('Membership requested');
});

test('an ignored request does not allow another request', async ({ page }) => {
  await page.goto('/dev/setup_manual_oatmilk_ignored_membership_request');
  await expect(page.locator('.group-page__name')).toBeVisible();
  await expect(joinButton(page)).toHaveCount(0);
  await expect(page.locator('.group-page')).not.toContainText('Your request to join was declined');
});

test('a parent group admin joins a closed subgroup', async ({ page, flash }) => {
  await page.goto('/dev/setup_group_with_subgroups_as_admin_landing_in_other_subgroup');
  await joinButton(page).click();
  await expect(flash).toContainText('You are now a member of Point Break - Bodhi');
});
