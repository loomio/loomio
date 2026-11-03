import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

async function openExample(page, kind) {
  await page.goto(`/dev/setup_manual_oatmilk_example?kind=${kind}`)
  await expect(page.locator('.topic-page').first()).toBeVisible()
  await expect(page.locator('.context-panel__heading').first()).toBeVisible()
}

async function revealPoll(page) {
  await expect(page.locator('.poll-created').first()).toBeVisible()
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

test('meeting_focus_2', async ({ page, manual: screenshot }) => {
  await openExample(page, 'meeting_focus');
  await expectLabel(page.locator('.topic-page'), 'bottle-return rates')
  await captureThread(screenshot, 'meeting_focus_2');
});

test('meeting_agenda', async ({ page, manual: screenshot }) => {
  await openExample(page, 'meeting_agenda');
  await revealPoll(page);
  await capturePoll(screenshot, 'meeting_agenda');
});

test('meeting_minutes', async ({ page, manual: screenshot }) => {
  await openExample(page, 'meeting_minutes');
  await revealPoll(page);
  await capturePoll(screenshot, 'meeting_minutes');
});

test('document_introduce', async ({ page, manual: screenshot }) => {
  await openExample(page, 'document_introduce');
  await expectLabel(page.locator('.topic-page'), 'damaged or missing bottles')
  await captureThread(screenshot, 'document_introduce');
  await captureGuide(screenshot, 'document_introduce');
});

test('document_integrate', async ({ page, manual: screenshot }) => {
  await openExample(page, 'document_integrate');
  await revealPoll(page);
  await capturePoll(screenshot, 'document_integrate');
  await captureGuide(screenshot, 'document_integrate');
});

test('document_approval', async ({ page, manual: screenshot }) => {
  await openExample(page, 'document_approval');
  await revealPoll(page);
  await capturePoll(screenshot, 'document_approval');
  await captureGuide(screenshot, 'document_approval');
});

test('document_outcome', async ({ page, manual: screenshot }) => {
  await openExample(page, 'document_outcome');
  await revealPoll(page);
  await expect(page.locator('.poll-common-outcome-panel').first()).toBeVisible()
  await screenshot.captureElement('discussions/examples/document_outcome', '.poll-common-outcome-panel', {
    width: 1100,
    height: 1000
  });
});

test('poll_minutes', async ({ page, manual: screenshot }) => {
  await openExample(page, 'board_minutes');
  await revealPoll(page);
  await expectLabel(page.locator('.topic-card'), 'Not voted')
  await captureGuide(screenshot, 'poll_minutes');
});

test('poll_approve_report', async ({ page, manual: screenshot }) => {
  await openExample(page, 'board_report');
  await revealPoll(page);
  await expectLabel(page.locator('.topic-card'), 'Not voted')
  await captureGuide(screenshot, 'poll_approve_report');
});

test('thread_funding', async ({ page, manual: screenshot }) => {
  await openExample(page, 'board_funding');
  await revealPoll(page);
  await expectLabel(page.locator('.topic-card'), 'Not voted')
  await captureGuide(screenshot, 'thread_funding');
});

test('thread_raise_issue', async ({ page, manual: screenshot }) => {
  await openExample(page, 'thread_raise_issue');
  await expectLabel(page.locator('.topic-page'), 'request capacity and water-use figures')
  await captureThread(screenshot, 'thread_raise_issue');
});
