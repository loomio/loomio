import { expect } from '../fixtures.mjs';

// Runs an action from the group page's settings menu.
export async function groupAction(page, action) {
  await page.locator('.group-page__actions .action-menu--btn').click();
  await page.locator(`.v-overlay--active .action-dock__button--${action}`).click();
}

// Opens the sidebar. Wide windows open it by themselves soon after loading,
// so only toggle it while it is closed, and retry until it stays open.
export async function openSidebar(page) {
  const drawer = page.locator('.sidenav-left');
  await expect(async () => {
    if (!/v-navigation-drawer--active/.test(await drawer.getAttribute('class') || '')) {
      await page.locator('.navbar__sidenav-toggle').click();
    }
    await expect(drawer).toHaveClass(/v-navigation-drawer--active/, { timeout: 1000 });
  }).toPass();
  await expect(drawer).toBeInViewport();
}

// A group or subgroup link in the sidebar, found by its name.
export function sidebarGroup(page, name) {
  return page.locator('.sidebar__group', { hasText: name });
}
