import { test, expect } from '../fixtures.mjs';

async function changeMembership(page, path) {
  const status = await page.execute(async path => (await fetch(path)).status, path);
  expect(status).toBe(200);
}

// A second real websocket proves the server stops group delivery even when a
// client ignores the membership change; no frontend records are mocked here.
async function subscribeProbe(page) {
  const subscribed = await page.execute(() => new Promise(done => {
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

test('leaving a group clears an authored poll needing a vote', async ({ lmo: page }) => {
  await page.loadPath('setup_group_with_authored_stv_poll');
  await page.click('.group-page-polls-tab');
  await page.expectText('.polls-panel', 'Working group election');
  await page.click('.action-menu');
  await page.click('.action-dock__button--leave_group');
  await page.click('.confirm-modal__submit');
  await page.expectFlash('You have left this group');
  await page.waitFor('.dashboard-page');
  await page.expectNoElement('.dashboard-page .poll-common-preview');
  await page.goTo('dashboard/polls_to_vote_on');
  await page.expectText('.polls-to-vote-on-page', 'There are no polls you need to vote on');
  await page.refreshAndWait();
  await page.expectText('.polls-to-vote-on-page', 'There are no polls you need to vote on');
});

test('administrator removal updates an open dashboard and stops private websocket delivery', async ({ lmo: page }) => {
  await page.loadPath('setup_group_with_authored_stv_poll');
  await page.goTo('dashboard/polls_to_vote_on');
  await page.expectText('.polls-to-vote-on-page', 'Working group election');
  await subscribeProbe(page);

  await changeMembership(page, '/dev/revoke_authored_poll_membership?by_admin=1');
  await page.expectText('.polls-to-vote-on-page', 'There are no polls you need to vote on');
  await page.expectNoElement('.polls-to-vote-on-page .poll-common-preview');
  await changeMembership(page, '/dev/publish_private_poll_update_after_removal');
  await page.pause(500);
  const value = await page.execute(() => ({
    revoked: window.__membershipMessages.some(message => message.membership_access?.revoked),
    privateUpdate: window.__membershipMessages.some(message =>
      (message.records?.polls || []).some(poll => poll.title === 'Private update after removal'))
  }));
  expect(value.revoked).toBe(true);
  expect(value.privateUpdate).toBe(false);
});

test('leaving in another tab clears the original dashboard without navigation', async ({ lmo: page }) => {
  await page.loadPath('setup_group_with_authored_stv_poll');
  await page.goTo('dashboard/polls_to_vote_on');
  await page.expectText('.polls-to-vote-on-page', 'Working group election');
  await subscribeProbe(page);
  const otherTab = await page.page.context().newPage();
  await otherTab.goto(new URL('/dev/revoke_authored_poll_membership', page.page.url()).href);
  await otherTab.close();
  await page.expectText('.polls-to-vote-on-page', 'There are no polls you need to vote on');
  await page.expectNoElement('.polls-to-vote-on-page .poll-common-preview');
  await page.waitForUrlToContain('/dashboard/polls_to_vote_on');
});

test('rejoining restores voting reminders in the existing browser page', async ({ lmo: page }) => {
  await page.loadPath('setup_group_with_authored_stv_poll');
  await page.goTo('dashboard/polls_to_vote_on');
  await page.expectText('.polls-to-vote-on-page', 'Working group election');
  await subscribeProbe(page);
  await changeMembership(page, '/dev/revoke_authored_poll_membership');
  await page.expectText('.polls-to-vote-on-page', 'There are no polls you need to vote on');

  await changeMembership(page, '/dev/restore_authored_poll_membership');
  await page.expectText('.polls-to-vote-on-page', 'Working group election');
  await page.expectElement('.polls-to-vote-on-page .poll-common-preview');
  await page.waitForUrlToContain('/dashboard/polls_to_vote_on');
});
