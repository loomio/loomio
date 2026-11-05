import { test, expect } from '../fixtures.mjs';
import { groupAction } from '../helpers/groups.mjs';

const pollsToVoteOn = page => page.locator('.polls-to-vote-on-page');
const noPolls = 'There are no polls you need to vote on';

async function change(page, path) {
  expect((await page.request.get(path)).ok()).toBe(true);
}

async function openPollsToVoteOn(page) {
  await page.goto('/dev/setup_group_with_authored_stv_poll');
  await page.goto('/dashboard/polls_to_vote_on');
  await expect(pollsToVoteOn(page)).toContainText('Working group election');
}

// A second real websocket proves the server stops group delivery even when a
// client ignores the membership change; no frontend records are mocked.
async function subscribeProbe(page) {
  const subscribed = await page.evaluate(() => new Promise(done => {
    window.__membershipMessages = [];
    const socket = new WebSocket(`${location.protocol === 'https:' ? 'wss' : 'ws'}://${location.host}/cable`,
      ['actioncable-v1-json', 'actioncable-unsupported']);
    socket.onopen = () => socket.send(JSON.stringify({
      command: 'subscribe', identifier: JSON.stringify({ channel: 'RecordsChannel' })
    }));
    socket.onmessage = event => {
      const data = JSON.parse(event.data);
      if (data.type === 'confirm_subscription') { done(true); }
      if (data.message) { window.__membershipMessages.push(data.message); }
    };
    socket.onerror = () => done(false);
  }));
  expect(subscribed).toBe(true);
  return () => page.evaluate(() => window.__membershipMessages);
}

test('leaving a group clears an authored poll needing a vote', async ({ page, flash }) => {
  await page.goto('/dev/setup_group_with_authored_stv_poll');
  await page.locator('.group-page-polls-tab').click();
  await expect(page.locator('.polls-panel')).toContainText('Working group election');
  await groupAction(page, 'leave_group');
  await page.locator('.confirm-modal__submit').click();
  await expect(flash).toContainText('You have left this group');
  await expect(page.locator('.dashboard-page')).toBeVisible();
  await expect(page.locator('.dashboard-page .poll-common-preview')).toHaveCount(0);
  await page.goto('/dashboard/polls_to_vote_on');
  await expect(pollsToVoteOn(page)).toContainText(noPolls);
});

test('removal by an admin updates an open dashboard and stops private websocket delivery', async ({ page }) => {
  await openPollsToVoteOn(page);
  const messages = await subscribeProbe(page);
  await change(page, '/dev/revoke_authored_poll_membership?by_admin=1');
  await expect(pollsToVoteOn(page)).toContainText(noPolls);
  await expect(pollsToVoteOn(page).locator('.poll-common-preview')).toHaveCount(0);

  await change(page, '/dev/publish_private_poll_update_after_removal');
  await expect.poll(async () => (await messages()).some(message => message.membership_access?.revoked)).toBe(true);
  const privateUpdate = (await messages()).some(message =>
    (message.records?.polls || []).some(poll => poll.title === 'Private update after removal'));
  expect(privateUpdate).toBe(false);
});

test('leaving in another tab clears the dashboard without navigating', async ({ page }) => {
  await openPollsToVoteOn(page);
  const otherTab = await page.context().newPage();
  await otherTab.goto('/dev/revoke_authored_poll_membership');
  await otherTab.close();
  await expect(pollsToVoteOn(page)).toContainText(noPolls);
  await expect(pollsToVoteOn(page).locator('.poll-common-preview')).toHaveCount(0);
  await expect(page).toHaveURL(/\/dashboard\/polls_to_vote_on/);
});

test('rejoining restores the poll to vote on in the open page', async ({ page }) => {
  await openPollsToVoteOn(page);
  await change(page, '/dev/revoke_authored_poll_membership');
  await expect(pollsToVoteOn(page)).toContainText(noPolls);
  await change(page, '/dev/restore_authored_poll_membership');
  await expect(pollsToVoteOn(page).locator('.poll-common-preview')).toContainText('Working group election');
  await expect(page).toHaveURL(/\/dashboard\/polls_to_vote_on/);
});
