import { expect } from '../fixtures.mjs';
import { editor } from './editor.mjs';

// Template keys under the chooser's "Poll" filter; the rest are proposals.
const POLL_TEMPLATES = ['poll', 'score', 'dot_vote', 'ranked_choice', 'stv', 'meeting'];

// Opens the new poll form for a template (config/poll_templates.yml key) from
// the thread's activity panel.
export async function openPollForm(page, template) {
  await page.locator('.activity-panel__add-poll').click();
  if (POLL_TEMPLATES.includes(template)) {
    await page.locator('.poll-common-choose-template__poll').click();
  }
  await page.locator(`.decision-tools-card__template--${template}`).click();
}

export async function fillPollForm(page, { title = 'A new proposal', details = 'Some details', options = [] } = {}) {
  await page.locator('.poll-common-form-fields__title input').fill(title);
  await editor(page.locator('.poll-common-form-fields__details')).fill(details);
  for (const option of options) {
    await page.locator('.poll-common-form__add-option-btn').click();
    await page.locator('.poll-option-form__name input').fill(option);
    await page.locator('.poll-option-form__done-btn').click();
  }
}

export async function submitPollForm(page) {
  await page.locator('.poll-common-form__submit').click();
  await expect(page.locator('.poll-common-form__submit')).toHaveCount(0);
}

// Starts a poll from the thread and reloads, so assertions see the saved poll.
export async function startPoll(page, template, fields) {
  await openPollForm(page, template);
  await fillPollForm(page, fields);
  await submitPollForm(page);
  await page.reload();
}

export async function expectPoll(page, { title = 'A new proposal', details = 'Some details' } = {}) {
  await expect(page.locator('.poll-common-card__title')).toContainText(title);
  await expect(page.locator('.poll-common-details-panel__details')).toContainText(details);
}

// Submits the vote form, with a reason when given. Choose an option first.
export async function submitVote(page, reason) {
  if (reason) {
    await editor(page.locator('.poll-common-vote-form__reason')).fill(reason);
  }
  await page.locator('.poll-common-vote-form__submit').click();
}

// A proposal's vote option by its icon (agree, abstain, disagree, block), or
// another poll's option by its name.
export function voteOption(page, option) {
  return ['agree', 'abstain', 'disagree', 'block'].includes(option)
    ? page.locator(`.poll-common-vote-form__button--${option}`)
    : page.locator('.poll-common-vote-form__button', { hasText: option });
}

// Runs an action from the poll's own menu (the thread header has another).
export async function pollAction(page, action) {
  await page.locator('.poll-created .action-menu--btn').click();
  await page.locator(`.v-overlay--active .action-dock__button--${action}`).click();
}

export async function openManageVoters(page) {
  await page.locator('.action-dock__button--announce_poll').click();
  return page.locator('.poll-members-form');
}
