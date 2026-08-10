const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function openExample(page, kind) {
  page.loadPath(`setup_manual_oatmilk_example?kind=${kind}`);
  page.waitFor('.strand-page');
  page.waitFor('.context-panel__heading');
}

function revealPoll(page) {
  page.waitFor('.poll-created');
}

function captureThread(screenshot, name) {
  screenshot.captureElement(`discussions/examples/${name}`, '.strand-card', {
    width: 1100,
    height: 1600
  });
}

function capturePoll(screenshot, name) {
  screenshot.captureElement(`discussions/examples/${name}`, '.strand-card', {
    width: 1100,
    height: 1800
  });
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'meeting_focus_2': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openExample(page, 'meeting_focus');
    page.expectText('.strand-page', 'bottle-return rates');
    captureThread(screenshot, 'meeting_focus_2');
  },

  'meeting_agenda': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openExample(page, 'meeting_agenda');
    revealPoll(page);
    capturePoll(screenshot, 'meeting_agenda');
  },

  'meeting_minutes': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openExample(page, 'meeting_minutes');
    revealPoll(page);
    capturePoll(screenshot, 'meeting_minutes');
  },

  'document_introduce': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openExample(page, 'document_introduce');
    page.expectText('.strand-page', 'damaged or missing bottles');
    captureThread(screenshot, 'document_introduce');
  },

  'document_integrate': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openExample(page, 'document_integrate');
    revealPoll(page);
    capturePoll(screenshot, 'document_integrate');
  },

  'document_approval': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openExample(page, 'document_approval');
    revealPoll(page);
    capturePoll(screenshot, 'document_approval');
  },

  'document_outcome': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openExample(page, 'document_outcome');
    revealPoll(page);
    page.waitFor('.poll-common-outcome-panel');
    screenshot.captureElement('discussions/examples/document_outcome', '.poll-common-outcome-panel', {
      width: 1100,
      height: 1000
    });
  },

  'thread_raise_issue': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openExample(page, 'thread_raise_issue');
    page.expectText('.strand-page', 'request capacity and water-use figures');
    captureThread(screenshot, 'thread_raise_issue');
  }
};
