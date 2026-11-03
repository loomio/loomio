// Adds a person or email address with the recipients autocomplete, as used to
// invite people, announce items and add voters.
export async function addRecipient(page, query, suggestion = query) {
  await page.locator('.recipients-autocomplete input[type="text"]').fill(query);
  await page.locator('.recipients-autocomplete-suggestion', { hasText: suggestion }).click();
}
