import { test, expect } from '../fixtures.mjs';
import { blockMainContentRequests } from '../helpers/initialPage.mjs';
import { choose } from '../helpers/vuetify.mjs';
import { box } from '../helpers/layout.mjs';
import { editor } from '../helpers/editor.mjs';
import { addRecipient } from '../helpers/recipients.mjs';
import {
  expectPoll, fillPollForm, openManageVoters, openPollForm, pollAction, startPoll, submitPollForm, submitVote, voteOption
} from '../helpers/polls.mjs';

const scenario = (pollType, name, extra = '') =>
  `/dev/polls/test_poll_scenario?scenario=${name}&poll_type=${pollType}${extra}`;
const reason = page => page.locator('.poll-common-stance-created__reason');

test('starts a direct poll from Direct threads and invites voters', async ({ page }) => {
  await page.goto('/dev/setup_discussion');
  await page.goto('/dashboard/direct_discussions');
  await page.locator('.topics-page__new-topic-button').click();
  await page.locator('.topics-page__new-poll-button').click();
  await page.locator('.poll-common-choose-template__poll').click();
  await page.locator('.decision-tools-card__template--poll').click();
  await expect(page.locator('.poll-common-form__group-select')).toContainText('None (direct discussion)');
  await fillPollForm(page, {title: 'Direct decision', options: ['Library', 'Town hall']});
  await submitPollForm(page);
  await expect(page.locator('.context-panel__breadcrumbs')).toContainText('Direct');
  await voteOption(page, 'Library').click();
  await submitVote(page);
  await expect(page.locator('.poll-common-current-vote')).toContainText('Library');
  const voters = await openManageVoters(page);
  await addRecipient(page, 'test@example.com');
  await voters.locator('.poll-members-form__submit').click();
  await expect(voters.locator('.poll-members-form__list')).toContainText('test@example.com');
  await voters.locator('.dismiss-modal-button').click();
  await page.goto('/dashboard/direct_discussions');
  await expect(page.locator('.topic-preview', {hasText: 'Direct decision'})).toBeVisible();
});

for (const [name, url, selector] of [
  ['standalone', '/dev/polls/test_scheduled_settings?opened=1', '.context-panel__heading'],
  ['embedded', scenario('proposal', 'poll_created'), '.poll-common-card__title']
]) {
  test(`${name} poll boots with its initial topic records`, async ({ page }) => {
    const requests = await blockMainContentRequests(page);
    await page.goto(url);
    await expect(page.locator(selector)).toBeVisible();
    expect(requests).toEqual([]);
  });
}

test.describe('starting polls in a thread', () => {
  test('a proposal, then voting with a reason', async ({ page }) => {
    await page.goto('/dev/polls/test_discussion');
    await startPoll(page, 'check');
    await expectPoll(page);
    await voteOption(page, 'agree').click();
    await submitVote(page, 'A reason');
    await expect(reason(page)).toContainText('A reason');
    await expect(page.locator('.poll-created .poll-common-current-vote')).toBeVisible();
  });

  test('a choose poll', async ({ page }) => {
    await page.goto('/dev/polls/test_discussion');
    await startPoll(page, 'poll', { options: ['An option', 'Another option'] });
    await expectPoll(page);
    await voteOption(page, 'An option').click();
    await submitVote(page, 'A reason');
    await expect(page.locator('.poll-common-current-vote')).toContainText('An option');
    await expect(reason(page)).toContainText('A reason');
  });

  test('an allocate poll', async ({ page }) => {
    await page.goto('/dev/polls/test_discussion');
    await startPoll(page, 'dot_vote', { options: ['An option'] });
    await expectPoll(page);
    await page.locator('.poll-dot-vote-vote-form__option .v-slider').click();
    await submitVote(page, 'A reason');
    await expect(page.locator('.poll-common-current-vote')).toContainText('An option');
    await expect(reason(page)).toContainText('A reason');
  });

  test('a score poll', async ({ page }) => {
    await page.goto('/dev/polls/test_discussion');
    await startPoll(page, 'score', { options: ['An option'] });
    await expectPoll(page);
    await page.locator('.poll-score-vote-form__score-slider').click();
    await submitVote(page, 'A reason');
    await expect(page.locator('.poll-common-current-vote')).toContainText('An option');
    await expect(reason(page)).toContainText('A reason');
  });

  test('a ranked choice poll', async ({ page }) => {
    await page.goto('/dev/polls/test_discussion');
    await startPoll(page, 'ranked_choice', { options: ['An option', 'Another option'] });
    await expectPoll(page);
    await expect(page.locator('.poll-ranked-choice-vote-form')).toBeVisible();
    await submitVote(page, 'My ranking');
    await expect(reason(page)).toContainText('My ranking');
  });

  test('a time poll in the author\'s time zone', async ({ page }) => {
    await page.goto('/dev/polls/test_discussion?time_zone=America%2FLos_Angeles');
    await openPollForm(page, 'meeting');
    await fillPollForm(page);
    const picker = page.locator('.date-time-picker');
    await expect(picker).toContainText('America/Los_Angeles');
    await page.locator('.date-time-picker__time-field input[role="combobox"]').fill('07:30');
    await expect(picker).toContainText('7:30 AM');
    await page.locator('.poll-meeting-form__option-button').click();
    await submitPollForm(page);
    await page.reload();

    await expectPoll(page);
    await expect(page.locator('.poll-meeting-time').first()).toContainText('7:30AM');
    await page.locator('.poll-meeting-vote-form--box').first().click();
    await submitVote(page, 'A reason');
    await expect(reason(page)).toContainText('A reason');
  });

  test('a proposal with results hidden until voting closes', async ({ page }) => {
    await page.goto('/dev/polls/test_discussion');
    await openPollForm(page, 'check');
    await fillPollForm(page);
    await page.locator('.poll-common-form__more-settings').click();
    await choose(page, '.poll-common-settings__hide-results', 'Until voting is closed');
    await submitPollForm(page);
    await page.reload();
    await expectPoll(page);
    await expect(page.locator('.poll-common-action-panel__results-hidden-until-closed')).toBeVisible();
  });

  test('an anonymous proposal hides voters and reasons until it closes', async ({ page }) => {
    await page.goto('/dev/polls/test_discussion');
    await openPollForm(page, 'check');
    await fillPollForm(page);
    await page.locator('.poll-common-form__more-settings').click();
    await expect(page.locator('.poll-common-form__anonymous-voting-explanation')).toContainText('Anonymous votes are stored separately from voter identities. Results only appear after voting closes, and voters cannot add reasons, review their vote after submitting it, or change it.');
    for (const [above, below] of [['anonymous-voting', 'weighted-voting'], ['weighted-voting', 'quorum'], ['quorum', 'reminder']]) {
      expect((await box(page.locator(`.poll-common-form__${above}-title`))).bottom)
        .toBeLessThanOrEqual((await box(page.locator(`.poll-common-form__${below}-title`))).y);
    }

    // Anonymous voting locks the settings that would reveal voters.
    await page.locator('.poll-settings-anonymous input').check();
    for (const [setting, value] of [
      ['.poll-common-settings__notify-on-closing-soon', "People who haven't voted"],
      ['.poll-common-settings__hide-results', 'Until voting is closed'],
      ['.poll-common-form__stance-reason-required', 'Disabled'],
    ]) {
      await expect(page.locator(setting)).toContainText(value);
      await expect(page.locator(setting)).toHaveClass(/v-input--disabled/);
    }
    await submitPollForm(page);
    await page.reload();

    const anonymousMessage = 'Voting is anonymous. You cannot review or change your vote after submitting it. Results are not available until voting has closed.';
    await expectPoll(page);
    await expect(page.locator('.poll-common-action-panel__anonymous-message')).toContainText(anonymousMessage);
    await expect(page.locator('.poll-common-action-panel__results-hidden-until-closed')).toHaveCount(0);

    await voteOption(page, 'agree').click();
    await submitVote(page);
    await expect(page.locator('.poll-common-action-panel__recorded')).toContainText('Your vote was recorded');
    await expect(page.locator('.poll-common-action-panel__anonymous-message')).toContainText(anonymousMessage);
    await expect(page.locator('.poll-common-vote-form')).toHaveCount(0);
    await expect(page.locator('.action-dock__button--view_votes')).toHaveCount(0);

    await page.locator('.action-dock__button--close_poll').click();
    await page.locator('.confirm-modal__submit').click();
    await expect(page.locator('.confirm-modal')).toHaveCount(0);
    await expect(page.locator('.poll-common-action-panel__anonymous-closed-message')).toContainText('Votes are anonymous');
    await expect(page.locator('.action-dock__button--view_votes')).toBeVisible();

    // Closing opens the outcome form. Its announcement can go to everyone
    // invited, but not to people chosen by how they voted.
    await page.locator('.poll-common-outcome-form .recipients-autocomplete input[type="text"]').click();
    const audiences = page.locator('.v-autocomplete__content');
    await expect(audiences).toContainText('Everyone invited to vote');
    await expect(audiences).not.toContainText('Everyone who voted');
    await expect(audiences).not.toContainText("People who haven't voted");
  });

  test('a proposal for selected voters only', async ({ page }) => {
    await page.goto('/dev/polls/test_discussion');
    await openPollForm(page, 'check');
    await fillPollForm(page);
    await page.locator('.poll-common-settings__specified-voters-only input').check();
    await page.locator('.poll-common-form__submit').click();

    const voters = page.locator('.poll-members-form');
    const notify = voters.locator('.v-checkbox');
    const message = voters.locator('.v-textarea');
    const submit = voters.locator('.poll-members-form__submit');
    await expect(voters.locator('.help-link')).toContainText('Help');
    await expect(submit).toHaveCount(0);
    await expect(notify).toHaveCount(0);

    await addRecipient(page, 'test@example.com');
    await expect(voters.locator('.poll-members-form__list')).toHaveCount(0);
    await expect(voters.locator('.poll-members-form__page-count')).toHaveCount(0);
    await page.keyboard.press('Escape');
    await expect(notify).toContainText('Send notifications');
    await expect(page.locator('.recipients-autocomplete .common-notifications-count')).toBeVisible();

    // The message sits above the notification choice, which shares a row with the submit button.
    const [messageBox, notifyBox, submitBox] = [await box(message), await box(notify), await box(submit)];
    expect(messageBox.bottom).toBeLessThanOrEqual(notifyBox.y);
    expect(notifyBox.x).toBeLessThan(submitBox.x);
    expect(notifyBox.y).toBeLessThan(submitBox.bottom);
    const messageGap = Math.min(notifyBox.y, submitBox.y) - messageBox.bottom;

    // Without notifications, a notice replaces the message at the same spacing.
    await notify.locator('input').uncheck();
    await expect(message).toHaveCount(0);
    const notice = voters.locator('.v-alert');
    await expect(notice).toContainText('Voters will not be notified. Let them know about the poll another way.');
    await expect(submit).toContainText('Add voters');
    const [noticeBox, rowNotify, rowSubmit] = [await box(notice), await box(notify), await box(submit)];
    expect(Math.abs(Math.min(rowNotify.y, rowSubmit.y) - noticeBox.bottom - messageGap)).toBeLessThanOrEqual(1);

    await notify.locator('input').check();
    await expect(message).toBeVisible();
    await submit.click();
    await expect(voters.locator('.poll-members-form__list')).toContainText('test@example.com');
    await voters.locator('.dismiss-modal-button').click();
    await page.reload();

    await expectPoll(page);
    await expect(page.locator('.poll-common-unable-to-vote')).toContainText('You have not been invited to vote');
  });

  test('a scheduled proposal shows a preview until voting opens', async ({ page }) => {
    await page.goto('/dev/polls/test_discussion');
    await openPollForm(page, 'check');
    await fillPollForm(page, { title: 'A scheduled proposal' });
    await page.locator('.poll-common-form__opens-immediately input').uncheck();
    await submitPollForm(page);
    await page.reload();
    await expect(page.locator('.poll-common-action-panel__scheduled')).toContainText('opens for voting');
    await expect(page.locator('.poll-common-vote-form--preview')).toBeVisible();
    await expect(page.locator('.poll-common-vote-form__button').first()).toBeVisible();
  });
});

test.describe('standalone polls', () => {
  test('starting a proposal outside a thread', async ({ page }) => {
    await page.goto('/dev/polls/start_poll');
    await page.locator('.decision-tools-card__template--check').click();
    await fillPollForm(page, { title: 'A standalone proposal' });
    await page.locator('.poll-common-form__submit').click();
    await expect(page.locator('.context-panel__heading')).toContainText('A standalone proposal');
    await expect(page.locator('.poll-common-details-panel__details')).toContainText('Some details');
  });
});

test.describe('voting', () => {
  test('the vote form closes after voting without a reason', async ({ page }) => {
    await page.goto(scenario('proposal', 'poll_created'));
    await voteOption(page, 'agree').click();
    await submitVote(page);
    await expect(page.locator('.poll-common-vote-form')).toHaveCount(0);
    await expect(page.locator('.poll-common-current-vote')).toBeVisible();
  });

  test('"none of the above" shows as the current vote', async ({ page }) => {
    await page.goto('/dev/polls/test_poll_scenario?scenario=poll_none_of_the_above');
    await expect(page.locator('.poll-common-current-vote')).toContainText('None of the above');
  });

  test('a voter can remove their vote', async ({ page, flash }) => {
    await page.goto(scenario('proposal', 'poll_closing_soon_with_vote'));
    await pollAction(page, 'uncast_stance');
    await expect(page.locator('.confirm-modal')).toContainText('Remove your vote?');
    await page.locator('.confirm-modal__submit').click();
    await expect(flash).toContainText('Vote removed');
  });

  test('a guest invited by email votes on an anonymous proposal', async ({ page, flash }) => {
    await page.goto('/dev/polls/test_poll_scenario.email?poll_type=proposal&scenario=poll_created&anonymous=1&guest=1');
    await page.locator('.notification-title__link--poll').click();
    await voteOption(page, 'agree').click();
    await submitVote(page);
    await expect(flash).toContainText('Vote created');
  });
});

test.describe('closed polls', () => {
  test('setting an outcome', async ({ page }) => {
    await page.goto(scenario('proposal', 'poll_closed'));
    await page.locator('.poll-common-set-outcome-panel__submit').click();
    await editor(page.locator('.poll-common-outcome-form__statement')).fill('This is an outcome');
    await page.locator('.poll-common-outcome-form__submit').click();
    await expect(page.locator('.poll-common-outcome-panel')).toContainText('This is an outcome');
  });

  test('a time poll outcome can include a calendar invite', async ({ page, flash }) => {
    await page.goto(scenario('meeting', 'poll_closed'));
    await page.locator('.poll-common-set-outcome-panel__submit').click();
    await editor(page.locator('.poll-common-outcome-form__statement')).fill('Here is a statement');
    await page.locator('.poll-common-calendar-invite__summary input').fill('This is a meeting title');
    await page.locator('.poll-common-calendar-invite__location input').fill('123 Any St, USA');
    await page.locator('.poll-common-outcome-form__submit').click();
    await expect(flash).toContainText('Outcome created');
  });

  test('reopening a poll offers to remind voters', async ({ page }) => {
    await page.goto(scenario('proposal', 'poll_closed'));
    await page.locator('.poll-created .action-dock__button--reopen_poll').click();
    await page.locator('.poll-common-reopen-form__submit').click();
    await expect(page.locator('.poll-remind')).toContainText('Remind to vote');
  });

  test('identified votes are listed in a table', async ({ page }) => {
    await page.goto(scenario('proposal', 'poll_closed'));
    await page.locator('.action-dock__button--view_votes').click();
    await expect(page.locator('.topic-header h1')).toContainText('Votes');
    await expect(page.locator('.topic-header .v-breadcrumbs')).not.toContainText('Votes');
    const heading = page.locator('.poll-common-votes-panel table thead');
    await expect(heading).toContainText('Name');
    await expect(heading).toContainText('Vote');
    await expect(heading).not.toContainText('Voted on');
  });

  test('migrated legacy anonymous votes do not show reasons', async ({ page }) => {
    await page.goto(scenario('proposal', 'poll_legacy_anonymous'));
    await page.locator('.action-dock__button--view_votes').click();
    const votes = page.locator('.poll-common-votes-panel');
    await expect(votes.locator('table')).toBeVisible();
    await expect(votes).not.toContainText('A plain text reason retained from the legacy vote');
  });
});

test.describe('managing voters', () => {
  test('a scheduled poll shows a preview and accepts new voters', async ({ page }) => {
    await page.goto('/dev/polls/test_scheduled_poll');
    await expect(page.locator('.poll-common-action-panel__scheduled')).toContainText('opens for voting');
    await expect(page.locator('.poll-common-vote-form--preview')).toBeVisible();

    const voters = await openManageVoters(page);
    const submit = voters.locator('.poll-members-form__submit');
    await expect(submit).toHaveCount(0);
    await expect(voters.locator('.v-checkbox')).toHaveCount(0);
    await addRecipient(page, 'test@example.com');
    await page.keyboard.press('Escape');
    await expect(submit).toContainText('Add voters');
  });

  test('an audience is counted before it is expanded into people', async ({ page }) => {
    await page.goto('/dev/polls/test_scheduled_poll');
    const voters = await openManageVoters(page);
    await page.locator('.recipients-autocomplete input[type="text"]').click();
    await expect(page.locator('.v-autocomplete__content')).not.toContainText('Everyone in the thread');
    await page.locator('.recipients-autocomplete-suggestion').first().click();

    const count = page.locator('.common-notifications-count');
    await expect(count).toContainText('people will be added');
    const people = (await count.innerText()).match(/\d+ people/)[0];
    await expect(voters.locator('.poll-members-form__list')).toHaveCount(0);

    await page.locator('.recipients-autocomplete .chip--select-multi').click();
    await expect(page.locator('.recipients-autocomplete .chip--select-multi [class*=user-avatar]').first()).toBeVisible();
    await expect(count).toContainText(people);

    await page.locator('.recipients-autocomplete .v-field__clearable').click();
    await expect(voters.locator('.poll-members-form__list')).toBeVisible();
    await expect(voters.locator('.poll-members-form__submit')).toHaveCount(0);
  });

  test('voters can be paged, searched and weighted', async ({ page, flash }) => {
    await page.goto('/dev/polls/test_scheduled_poll?vote_count=25&weighted=1');
    const voters = await openManageVoters(page);
    const pageCount = voters.locator('.poll-members-form__page-count');
    const search = page.locator('.recipients-autocomplete input[type="text"]');
    await expect(voters).toContainText('Manage voters');
    await expect(pageCount).toContainText('1–25 of 25');

    const weight = voters.locator('.poll-members-form__weight').first();
    await weight.click();
    // The weight editor opens in an overlay outside the voters modal.
    const weightInput = page.locator('.poll-members-form__weight-input input');
    await weightInput.fill('2');
    await weightInput.press('Enter');
    await expect(flash).toContainText('Vote weights updated');
    await expect(weight).toContainText('2');

    const setAll = page.locator('.poll-members-form__set-all-dialog');
    await voters.locator('.poll-members-form__set-all').click();
    await expect(setAll).toContainText('Set all vote weights');
    await expect(setAll).toContainText("Set each member's default vote weight");
    await page.locator('.poll-members-form__set-all-cancel').click();

    // Setting every weight during a search still applies to everyone.
    await search.fill('No matching voter');
    await expect(pageCount).toContainText('0–0 of 0');
    await voters.locator('.poll-members-form__set-all').click();
    await expect(page.locator('.poll-members-form__set-all-search-note')).toContainText('including those outside your search results');
    await page.locator('.poll-members-form__set-all-cancel').click();
    await expect(page.locator('.recipients-autocomplete__no-data')).toHaveCount(0);
    await pageCount.click();
    await expect(search).toHaveValue('No matching voter');

    await page.locator('.recipients-autocomplete .v-field__clearable').click();
    await expect(search).toHaveValue('');
    await expect(pageCount).toContainText('1–25 of 25');
  });

  test('removing a voter asks for confirmation', async ({ page }) => {
    await page.goto('/dev/polls/test_scheduled_poll?vote_count=4');
    const voters = await openManageVoters(page);
    const pageCount = voters.locator('.poll-members-form__page-count');
    await expect(pageCount).toContainText('1–4 of 4');
    await voters.locator('.poll-members-form__remove').first().click();
    await expect(page.locator('.poll-members-form__remove-dialog')).toContainText('This also removes any vote they cast.');
    await page.locator('.poll-members-form__cancel-remove').click();
    await expect(pageCount).toContainText('1–4 of 4');
    await voters.locator('.poll-members-form__remove').first().click();
    await page.locator('.poll-members-form__confirm-remove').click();
    await expect(pageCount).toContainText('1–3 of 3');
  });

  test('fifty weighted voters fit inside the modal', async ({ page }) => {
    await page.goto('/dev/polls/test_many_weighted_voters');
    const table = page.locator('.poll-common-chart-table');
    const slices = table.locator('.poll-proposal-chart path');
    await expect(page.locator('.poll-common-chart-panel__variable-vote-weights')).toContainText('Votes in this poll have different weights, so some count more than others.');
    await expect(table.locator('tbody tr', { hasText: '+33' })).toContainText('70');
    await expect(slices).toHaveCount(4);

    // Switching between plain and weighted results redraws the chart.
    await table.locator('thead th').nth(3).locator('button').click();
    await expect(slices).toHaveCount(5);
    await expect(table.locator('.poll-proposal-chart path[fill="#BBBBBB"]')).toBeVisible();
    await table.locator('thead th').nth(5).locator('button').click();
    await expect(slices).toHaveCount(4);

    const voters = await openManageVoters(page);
    await expect(voters.locator('.poll-members-form__page-count')).toContainText('1–50 of 50');
    await expect(voters.locator('.poll-members-form__list .v-list-item').first()).toContainText('Voter 45');
    const weights = await voters.locator('.poll-members-form__weight').allInnerTexts();
    expect(new Set(weights).size, 'voters have different vote weights').toBeGreaterThan(1);
    expect((await box(voters)).height, 'modal fits within 90% of the viewport').toBeLessThanOrEqual(page.viewportSize().height * 0.9 + 1);
    const list = voters.locator('.poll-members-form__list');
    expect(await list.evaluate(el => el.scrollHeight > el.clientHeight), 'voter list scrolls within the modal').toBe(true);
  });

  test('weighted voters are paged after fifty', async ({ page }) => {
    await page.goto('/dev/polls/test_many_weighted_voters?vote_count=55');
    const voters = await openManageVoters(page);
    const pageCount = voters.locator('.poll-members-form__page-count');
    await expect(pageCount).toContainText('1–50 of 55');
    await expect(voters.locator('.poll-members-form__list .v-list-item').first()).toContainText('Voter 50');
    await voters.locator('.poll-members-form__pagination .v-pagination__next button').click();
    await expect(pageCount).toContainText('51–55 of 55');
  });
});

test.describe('weighted voting settings', () => {
  const weighted = page => page.locator('.poll-settings-weighted-voting input');
  const quorum = page => page.locator('.poll-common-form__quorum');
  const quorumHelp = page => page.locator('.poll-common-form__quorum-title + .text-body-medium');

  test('weighted voting changes how quorum is measured', async ({ page }) => {
    await page.goto('/dev/polls/start_poll?weighted=1');
    await page.locator('.decision-tools-card__template--check').click();
    await page.locator('.poll-common-form__more-settings').click();
    for (const [above, below] of [['anonymous-voting', 'weighted-voting'], ['weighted-voting', 'quorum']]) {
      expect((await box(page.locator(`.poll-common-form__${above}-title`))).bottom)
        .toBeLessThanOrEqual((await box(page.locator(`.poll-common-form__${below}-title`))).y);
    }
    await expect(quorumHelp(page)).toContainText('What percentage of voters must participate');
    await expect(quorum(page).locator('input')).toHaveAttribute('placeholder', 'Percentage of eligible voters (0–100)');
    await expect(page.locator('.poll-common-form')).toContainText('Give voters different vote weights. Results show both the plain and the weighted totals.');
    for (const path of ['quorum', 'weighted_voting', 'anonymous_voting', 'settings#reminder', 'settings#vote-reason', 'settings#hide-results', 'settings#duration']) {
      await expect(page.locator(`a[href$="/docs/en/user_manual/polls/${path}"]`)).toBeVisible();
    }
    await expect(page.locator('a[href$="/docs/en/user_manual/polls/weighted_voting"]')).toContainText('Read more');

    await weighted(page).check();
    await expect(quorumHelp(page)).toContainText('What percentage of eligible vote weight must participate');
    await expect(quorum(page).locator('input')).toHaveAttribute('placeholder', 'Percentage of eligible vote weight (0–100)');
    await quorum(page).locator('input').fill('60');

    await weighted(page).uncheck();
    await expect(quorumHelp(page)).toContainText('What percentage of voters must participate');
    await expect(quorum(page).locator('input')).toHaveValue('60');
  });

  test('anonymous voting turns off weighted voting', async ({ page }) => {
    await page.goto('/dev/polls/start_poll');
    await page.locator('.decision-tools-card__template--check').click();
    await page.locator('.poll-common-form__more-settings').click();
    await weighted(page).check();
    await page.locator('.poll-settings-anonymous input').check();
    await expect(weighted(page)).toBeDisabled();
    await expect(weighted(page)).not.toBeChecked();
    await expect(page.locator('.poll-common-form')).toContainText('Weighted voting is not available with anonymous voting');
  });

  for (const [state, params, warning] of [
    ['on', '', "Turning on weighted voting copies each member's default vote weight."],
    ['off', '?weighted=1', 'Turning off weighted voting sets every vote weight to 1'],
  ]) {
    test(`turning weighted voting ${state} on an open poll warns that issued weights change`, async ({ page }) => {
      await page.goto(`/dev/polls/edit_open_poll_vote_weights${params}`);
      await page.locator('.poll-common-form__more-settings').click();
      await weighted(page).click();
      const form = page.locator('.poll-common-form');
      await expect(form).toContainText('Vote weights already issued will change.');
      await expect(form).toContainText(warning);
    });
  }
});
