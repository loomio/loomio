import { expect } from '../fixtures.mjs';

// Runs an action from the group page's settings menu.
export async function groupAction(page, action) {
  await page.locator('.group-page__actions .action-menu--btn').click();
  await page.locator(`.v-overlay--active .action-dock__button--${action}`).click();
}

// Makes sure the sidebar is open. Wide windows open it by themselves soon after
// loading, so toggle it only while it is closed, and retry until it stays open.
// In narrow windows the sidebar is an overlay that closes on any route change,
// including the router's first navigation, so wait for that to finish.
export async function ensureSidebar(page) {
  const drawer = page.locator('.sidenav-left');
  await page.waitForFunction(() => document.querySelector('#app')?.__vue_app__?.config.globalProperties.$router.isReady().then(() => true));
  await expect(async () => {
    if (!/v-navigation-drawer--active/.test(await drawer.getAttribute('class') || '')) {
      await page.locator('.navbar__sidenav-toggle').click();
    }
    await expect(drawer).toHaveClass(/v-navigation-drawer--active/, { timeout: 1000 });
    await expect(drawer).toBeInViewport({ timeout: 1000 });
  }).toPass();
}

// A group or subgroup link in the sidebar, found by its name.
export function sidebarGroup(page, name) {
  return page.locator('.sidebar__group', { hasText: name });
}
