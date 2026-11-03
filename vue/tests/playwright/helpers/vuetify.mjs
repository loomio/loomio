// Opens a Vuetify select or autocomplete and picks an option. Vuetify draws
// the field over the input, so click the field; its options have no classes
// of their own, so they are matched by their text.
export async function choose(page, select, option) {
  await page.locator(`${select} .v-field`).click();
  await page.locator('.v-overlay--active .v-list-item', { hasText: option }).click();
}
