// A row in the group's members list, found by the member's name.
export function member(page, name) {
  return page.locator('.members-panel__member', { hasText: name });
}

// Runs an action from a member's dropdown, such as remove or toggle-admin.
export async function memberAction(page, name, action) {
  await member(page, name).locator('.membership-dropdown__button').click();
  await page.locator(`.v-overlay--active .membership-dropdown__${action}`).click();
}

export async function openMembers(page) {
  await page.locator('.group-page-members-tab').click();
}
