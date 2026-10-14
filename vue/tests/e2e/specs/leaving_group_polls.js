const pageHelper = require('../helpers/pageHelper');

function changeMembership(test, path) {
  test.executeAsync((path, done) => {
    fetch(path).then(response => done(response.status)).catch(() => done(0));
  }, [path], ({value}) => test.assert.strictEqual(value, 200));
}

// A second real websocket proves the server stops group delivery even when a
// client ignores the membership change; no frontend records are mocked here.
function subscribeProbe(test) {
  test.executeAsync(done => {
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
  }, [], ({value}) => test.assert.strictEqual(value, true));
}

module.exports = {
  'leaving a group clears an authored poll needing a vote': test => {
    const page = pageHelper(test);
    page.loadPath('setup_group_with_authored_stv_poll');
    page.click('.group-page-polls-tab');
    page.expectText('.polls-panel', 'Working group election');
    page.click('.action-menu');
    page.click('.action-dock__button--leave_group');
    page.click('.confirm-modal__submit');
    page.expectFlash('You have left this group');
    page.waitFor('.dashboard-page');
    page.expectNoElement('.dashboard-page .poll-common-preview');
    page.goTo('dashboard/polls_to_vote_on');
    page.expectText('.polls-to-vote-on-page', 'There are no polls you need to vote on');
    page.refreshAndWait();
    page.expectText('.polls-to-vote-on-page', 'There are no polls you need to vote on');
  },

  'administrator removal updates an open dashboard and stops private websocket delivery': test => {
    const page = pageHelper(test);
    page.loadPath('setup_group_with_authored_stv_poll');
    page.goTo('dashboard/polls_to_vote_on');
    page.expectText('.polls-to-vote-on-page', 'Working group election');
    subscribeProbe(test);

    changeMembership(test, '/dev/revoke_authored_poll_membership?by_admin=1');
    page.expectText('.polls-to-vote-on-page', 'There are no polls you need to vote on');
    page.expectNoElement('.polls-to-vote-on-page .poll-common-preview');
    changeMembership(test, '/dev/publish_private_poll_update_after_removal');
    page.pause(500);
    test.execute(() => ({
      revoked: window.__membershipMessages.some(message => message.membership_access?.revoked),
      privateUpdate: window.__membershipMessages.some(message =>
        (message.records?.polls || []).some(poll => poll.title === 'Private update after removal'))
    }), [], ({value}) => {
      test.assert.strictEqual(value.revoked, true);
      test.assert.strictEqual(value.privateUpdate, false);
    });
  },

  'leaving in another tab clears the original dashboard without navigation': test => {
    const page = pageHelper(test);
    page.loadPath('setup_group_with_authored_stv_poll');
    page.goTo('dashboard/polls_to_vote_on');
    page.expectText('.polls-to-vote-on-page', 'Working group election');
    subscribeProbe(test);
    test.perform(async () => {
      const original = await test.driver.getWindowHandle();
      const url = await test.driver.getCurrentUrl();
      await test.driver.switchTo().newWindow('tab');
      await test.driver.get(new URL('/dev/revoke_authored_poll_membership', url).href);
      await test.driver.close();
      await test.driver.switchTo().window(original);
    });
    page.expectText('.polls-to-vote-on-page', 'There are no polls you need to vote on');
    page.expectNoElement('.polls-to-vote-on-page .poll-common-preview');
    test.assert.urlContains('/dashboard/polls_to_vote_on');
  },

  'rejoining restores voting reminders in the existing browser page': test => {
    const page = pageHelper(test);
    page.loadPath('setup_group_with_authored_stv_poll');
    page.goTo('dashboard/polls_to_vote_on');
    page.expectText('.polls-to-vote-on-page', 'Working group election');
    subscribeProbe(test);
    changeMembership(test, '/dev/revoke_authored_poll_membership');
    page.expectText('.polls-to-vote-on-page', 'There are no polls you need to vote on');

    changeMembership(test, '/dev/restore_authored_poll_membership');
    page.expectText('.polls-to-vote-on-page', 'Working group election');
    page.expectElement('.polls-to-vote-on-page .poll-common-preview');
    test.assert.urlContains('/dashboard/polls_to_vote_on');
  }
};
