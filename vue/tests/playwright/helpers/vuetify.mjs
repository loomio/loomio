// Vuetify draws a select's field over its input, and its options have no
// classes of their own, so these click the field and match options by text.

// Opens a select or autocomplete and picks an option.
export async function choose(page, select, option) {
  await page.locator(`${select} .v-field`).click();
  await page.locator('.v-overlay--active .v-list-item', { hasText: option }).click();
}

// Types into an autocomplete and picks a matching result.
export async function search(page, autocomplete, query, option = query) {
  await page.locator(`${autocomplete} input`).fill(query);
  await page.locator('.v-overlay--active .v-list-item', { hasText: option }).click();
}
