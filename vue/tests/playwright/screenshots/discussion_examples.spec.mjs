import { test, expect } from '../screenshotFixtures.mjs';

async function openExample(page, kind) {
  await page.loadPath(`setup_manual_oatmilk_example?kind=${kind}`);
  await page.waitFor('.topic-page');
  await page.waitFor('.context-panel__heading');
}

async function revealPoll(page) {
  await page.waitFor('.poll-created');
}

async function captureThread(screenshot, name) {
  await screenshot.captureElement(`discussions/examples/${name}`, '.topic-card', {
    width: 1100,
    height: 1600
  });
}

async function capturePoll(screenshot, name) {
  await screenshot.captureElement(`discussions/examples/${name}`, '.topic-card', {
    width: 1100,
    height: 1800
  });
}

// The board processes guide shows the same examples next to its own pages.
async function captureGuide(screenshot, name) {
  await screenshot.captureElement(`guides/board_processes/${name}`, '.topic-card', {
    width: 1100,
    height: 1800
  });
}

test('meeting_focus_2', async ({ lmo: page, manual: screenshot }) => {
  await openExample(page, 'meeting_focus');
  await page.expectText('.topic-page', 'bottle-return rates');
  await captureThread(screenshot, 'meeting_focus_2');
});

test('meeting_agenda', async ({ lmo: page, manual: screenshot }) => {
  await openExample(page, 'meeting_agenda');
  await revealPoll(page);
  await capturePoll(screenshot, 'meeting_agenda');
});

test('meeting_minutes', async ({ lmo: page, manual: screenshot }) => {
  await openExample(page, 'meeting_minutes');
  await revealPoll(page);
  await capturePoll(screenshot, 'meeting_minutes');
});

test('document_introduce', async ({ lmo: page, manual: screenshot }) => {
  await openExample(page, 'document_introduce');
  await page.expectText('.topic-page', 'damaged or missing bottles');
  await captureThread(screenshot, 'document_introduce');
  await captureGuide(screenshot, 'document_introduce');
});

test('document_integrate', async ({ lmo: page, manual: screenshot }) => {
  await openExample(page, 'document_integrate');
  await revealPoll(page);
  await capturePoll(screenshot, 'document_integrate');
  await captureGuide(screenshot, 'document_integrate');
});

test('document_approval', async ({ lmo: page, manual: screenshot }) => {
  await openExample(page, 'document_approval');
  await revealPoll(page);
  await capturePoll(screenshot, 'document_approval');
  await captureGuide(screenshot, 'document_approval');
});

test('document_outcome', async ({ lmo: page, manual: screenshot }) => {
  await openExample(page, 'document_outcome');
  await revealPoll(page);
  await page.waitFor('.poll-common-outcome-panel');
  await screenshot.captureElement('discussions/examples/document_outcome', '.poll-common-outcome-panel', {
    width: 1100,
    height: 1000
  });
});

test('poll_minutes', async ({ lmo: page, manual: screenshot }) => {
  await openExample(page, 'board_minutes');
  await revealPoll(page);
  await page.expectText('.topic-card', 'Not voted');
  await captureGuide(screenshot, 'poll_minutes');
});

test('poll_approve_report', async ({ lmo: page, manual: screenshot }) => {
  await openExample(page, 'board_report');
  await revealPoll(page);
  await page.expectText('.topic-card', 'Not voted');
  await captureGuide(screenshot, 'poll_approve_report');
});

test('thread_funding', async ({ lmo: page, manual: screenshot }) => {
  await openExample(page, 'board_funding');
  await revealPoll(page);
  await page.expectText('.topic-card', 'Not voted');
  await captureGuide(screenshot, 'thread_funding');
});

test('thread_raise_issue', async ({ lmo: page, manual: screenshot }) => {
  await openExample(page, 'thread_raise_issue');
  await page.expectText('.topic-page', 'request capacity and water-use figures');
  await captureThread(screenshot, 'thread_raise_issue');
});
