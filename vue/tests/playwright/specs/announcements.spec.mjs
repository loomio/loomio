import { test, expect } from '../fixtures.mjs';
import { openPollForm, fillPollForm } from '../helpers/polls.mjs';
import { addRecipient } from '../helpers/recipients.mjs';
import { openThreadForm } from '../helpers/threads.mjs';

const recipientsInput = page => page.locator('.recipients-autocomplete input[type="text"]');
const suggestions = page => page.locator('.recipients-autocomplete-suggestion');

async function openInviteForm(page) {
  await page.locator('.group-page-members-tab').click();
  await page.locator('.membership-card__invite').click();
}

test.describe('inviting people to a group', () => {
  test('invites by email', async ({ page, flash }) => {
    await page.goto('/dev/setup_group');
    await openInviteForm(page);
    await addRecipient(page, 'test@example.com');
    await page.locator('.announcement-form__submit').click();
    await expect(flash).toContainText('1 notifications sent');
  });

  test.describe('to a subgroup', () => {
    test.beforeEach(async ({ page }) => {
      await page.goto('/dev/setup_subgroup_invitation_audiences');
      await openInviteForm(page);
      await recipientsInput(page).click();
    });

    test('expands the parent group into its members', async ({ page }) => {
      await suggestions(page).filter({ hasText: 'Point Break' }).click();
      await page.locator('.recipients-autocomplete .chip--select-multi').click();
      await expect(page.locator('.recipients-autocomplete')).toContainText('Max Von Sydow');
      await expect(page.locator('.recipients-autocomplete')).not.toContainText('Jennifer Grey');
    });

    test('invites the parent group without expanding it', async ({ page, flash }) => {
      await suggestions(page).filter({ hasText: 'Point Break' }).click();
      await page.locator('.announcement-form__submit').click();
      await expect(flash).toContainText('1 notifications sent');
      await expect(page.locator('.members-panel')).toContainText('Max Von Sydow');
    });
  });
});

test.describe('notifying people about a new thread', () => {
  test('in a group', async ({ page, flash }) => {
    await page.goto('/dev/setup_group');
    await openThreadForm(page);
    await addRecipient(page, 'test@example.com');
    await page.locator('.discussion-form__title-input input').fill('Immannounce dis');
    await page.locator('.discussion-form__submit').click();
    await expect(flash).toContainText('Discussion started');
  });

  test('a direct thread suggests email addresses without a group', async ({ page }) => {
    await page.goto('/dev/setup_discussion');
    await page.locator('.navbar__sidenav-toggle').click();
    await page.locator('.sidebar__list-item-button--private').click();
    await page.locator('.topics-page__new-topic-button').click();
    await page.locator('.discussion-templates--direct-discussion').click();
    await recipientsInput(page).fill('test@example.com');
    await expect(suggestions(page)).toContainText(['test@example.com']);
  });
});

test.describe('managing thread members', () => {
  const members = page => page.locator('.topic-members-list');

  const openMembers = async (page, scenario = 'setup_discussion') => {
    await page.goto(`/dev/${scenario}`);
    await page.locator('.action-dock__button--announce_thread').click();
  };

  test('invites someone by email', async ({ page, flash }) => {
    await openMembers(page);
    await addRecipient(page, 'test@example.com');
    await page.keyboard.press('Escape');
    await page.locator('.topic-members-list__submit').click();
    await expect(flash).toContainText('1 notifications sent');
    await expect(members(page)).toContainText('test@example.com');
  });

  test('suggests group members by name', async ({ page }) => {
    await openMembers(page);
    await recipientsInput(page).fill('Emilio');
    await expect(suggestions(page).filter({ hasText: 'Emilio Estevez' })).toBeVisible();
  });

  test('pages and filters the members', async ({ page }) => {
    await openMembers(page, 'setup_discussion_many_members');
    const pageCount = page.locator('.topic-members-list__page-count');
    const readers = page.locator('.topic-members-list__readers');
    const clear = page.locator('.recipients-autocomplete .v-field__clearable');
    const message = members(page).locator('textarea');
    const submit = page.locator('.topic-members-list__submit');
    const guestHelp = 'Guests invited by email can participate';

    await expect(members(page)).toContainText('Manage thread members');
    await expect(members(page).locator('.help-link')).toBeVisible();
    await expect(pageCount).toContainText('1–50 of 52');
    await expect(readers).toContainText('Thread member 50');
    await page.locator('.topic-members-list__pagination .v-pagination__next button').click();
    await expect(pageCount).toContainText('51–52 of 52');

    // Typing filters the members; clicking elsewhere keeps the filter.
    await recipientsInput(page).fill('Thread member 50');
    await expect(pageCount).toContainText('1–1 of 1');
    await pageCount.click();
    await expect(recipientsInput(page)).toHaveValue('Thread member 50');
    await clear.click();
    await expect(pageCount).toContainText('1–50 of 52');

    // Adding someone switches the list to the invitation form.
    await expect(message).toHaveCount(0);
    await expect(submit).toHaveCount(0);
    await addRecipient(page, 'test@example.com');
    await expect(message).toBeVisible();
    await expect(submit).toBeVisible();
    await expect(members(page)).toContainText('New people will be invited to the thread');
    await expect(readers).toHaveCount(0);
    await clear.click();
    await expect(readers).toBeVisible();

    // A dismissed help alert stays dismissed.
    await members(page).locator('.v-alert__close button').click();
    await expect(members(page)).not.toContainText(guestHelp);
    await members(page).locator('.dismiss-modal-button').click();
    await page.locator('.action-dock__button--announce_thread').click();
    await expect(members(page)).not.toContainText(guestHelp);
  });
});

test('a poll for selected voters offers people but not the whole thread', async ({ page, flash }) => {
  await page.goto('/dev/setup_discussion');
  await openPollForm(page, 'check');
  await fillPollForm(page);
  await page.locator('.poll-common-settings__specified-voters-only input').check();
  await page.locator('.poll-common-form__submit').click();
  await expect(flash).toContainText('Proposal started');

  await recipientsInput(page).click();
  await expect(suggestions(page).first()).toBeVisible();
  await expect(page.locator('.v-autocomplete__content')).not.toContainText('Everyone in the thread');
  await addRecipient(page, 'test@example.com');
  await page.keyboard.press('Escape');
  await page.locator('.poll-members-form__submit').click();
  await expect(flash).toContainText('1 notifications sent');
});
