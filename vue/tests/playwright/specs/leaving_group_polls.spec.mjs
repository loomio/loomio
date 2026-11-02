import { test, expect } from '../fixtures.mjs';

async function changeMembership(page, path) {
  const status = await page.evaluate(async path => (await fetch(path)).status, path);
  expect(status).toBe(200);
}

// A second real websocket proves the server stops group delivery even when a
// client ignores the membership change; no frontend records are mocked here.
async function subscribeProbe(page) {
  const subscribed = await page.evaluate(() => new Promise(done => {
    window.__membershipMessages = [];
    const socket = new WebSocket(`${location.protocol === 'https:' ? 'wss' : 'ws'}://${location.host}/cable`,
      ['actioncable-v1-json', 'actioncable-unsupported']);
    window.__membershipProbe = socket;
    socket.onopen = () => socket.send(JSON.stringify({
      command: 'subscribe', identifier: JSON.stringify({channel: 'RecordsChannel'})
    }));
    socket.onmessage = event => {
      const data = JSON.parse(event.data);
      if (data.type === 'confirm_subscription') { done(true); }
      if (data.message) { window.__membershipMessages.push(data.message); }
    };
    socket.onerror = () => done(false);
  }));
  expect(subscribed).toBe(true);
}

test('leaving a group clears an authored poll needing a vote', async ({ page }) => {
  await page.goto('/dev/setup_group_with_authored_stv_poll')
  await page.click('.group-page-polls-tab')
  await expect(page.locator('.polls-panel')).toContainText('Working group election')
  await page.click('.action-menu')
  await page.click('.action-dock__button--leave_group')
  await page.click('.confirm-modal__submit')
  await expect(page.locator('.flash-root__message')).toContainText('You have left this group')
  await expect(page.locator('.dashboard-page')).toBeVisible()
  await expect(page.locator('.dashboard-page .poll-common-preview')).toHaveCount(0)
  await page.goto('/dashboard/polls_to_vote_on')
  await expect(page.locator('.polls-to-vote-on-page')).toContainText('There are no polls you need to vote on')
  await page.reload()
  await expect(page.locator('.polls-to-vote-on-page')).toContainText('There are no polls you need to vote on')
});

test('administrator removal updates an open dashboard and stops private websocket delivery', async ({ page }) => {
  await page.goto('/dev/setup_group_with_authored_stv_poll')
  await page.goto('/dashboard/polls_to_vote_on')
  await expect(page.locator('.polls-to-vote-on-page')).toContainText('Working group election')
  await subscribeProbe(page);

  await changeMembership(page, '/dev/revoke_authored_poll_membership?by_admin=1');
  await expect(page.locator('.polls-to-vote-on-page')).toContainText('There are no polls you need to vote on')
  await expect(page.locator('.polls-to-vote-on-page .poll-common-preview')).toHaveCount(0)
  await changeMembership(page, '/dev/publish_private_poll_update_after_removal');
  const value = await page.evaluate(() => ({
    revoked: window.__membershipMessages.some(message => message.membership_access?.revoked),
    privateUpdate: window.__membershipMessages.some(message =>
      (message.records?.polls || []).some(poll => poll.title === 'Private update after removal'))
  }));
  expect(value.revoked).toBe(true);
  expect(value.privateUpdate).toBe(false);
});

test('leaving in another tab clears the original dashboard without navigation', async ({ page }) => {
  await page.goto('/dev/setup_group_with_authored_stv_poll')
  await page.goto('/dashboard/polls_to_vote_on')
  await expect(page.locator('.polls-to-vote-on-page')).toContainText('Working group election')
  await subscribeProbe(page);
  const otherTab = await page.context().newPage();
  await otherTab.goto(new URL('/dev/revoke_authored_poll_membership', page.url()).href);
  await otherTab.close();
  await expect(page.locator('.polls-to-vote-on-page')).toContainText('There are no polls you need to vote on')
  await expect(page.locator('.polls-to-vote-on-page .poll-common-preview')).toHaveCount(0)
  await expect(page).toHaveURL(/\/dashboard\/polls_to_vote_on/)
});

test('rejoining restores voting reminders in the existing browser page', async ({ page }) => {
  await page.goto('/dev/setup_group_with_authored_stv_poll')
  await page.goto('/dashboard/polls_to_vote_on')
  await expect(page.locator('.polls-to-vote-on-page')).toContainText('Working group election')
  await subscribeProbe(page);
  await changeMembership(page, '/dev/revoke_authored_poll_membership');
  await expect(page.locator('.polls-to-vote-on-page')).toContainText('There are no polls you need to vote on')

  await changeMembership(page, '/dev/restore_authored_poll_membership');
  await expect(page.locator('.polls-to-vote-on-page')).toContainText('Working group election')
  await expect(page.locator('.polls-to-vote-on-page .poll-common-preview')).toBeVisible()
  await expect(page).toHaveURL(/\/dashboard\/polls_to_vote_on/)
});
