// Runs an action from the group page's settings menu.
export async function groupAction(page, action) {
  await page.locator('.group-page__actions .action-menu--btn').click();
  await page.locator(`.v-overlay--active .action-dock__button--${action}`).click();
}

export async function openSidebar(page) {
  await page.locator('.navbar__sidenav-toggle').click();
}

// A group or subgroup link in the sidebar, found by its name.
export function sidebarGroup(page, name) {
  return page.locator('.sidebar__group', { hasText: name });
}
