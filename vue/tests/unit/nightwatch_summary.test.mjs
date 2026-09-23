import assert from 'node:assert/strict';
import test from 'node:test';

import { renderNightwatchSummary, summarizeNightwatchReports } from '../nightwatch_summary.mjs';

const reports = [{
  name: 'poll',
  report: {
    time: '65.4',
    completed: {
      'creates a time poll': {
        status: 'pass', passed: 3, failed: 0, errors: 0, skipped: 0, tests: 3
      },
      'edits a time poll': {
        status: 'fail', passed: 1, failed: 1, errors: 0, skipped: 0, tests: 2,
        assertions: [{ failure: false, fullMsg: 'setup passed' }, { failure: 'expected visible', fullMsg: 'Element <.poll-common-card> was not visible' }]
      }
    }
  }
}];

test('summarizes Nightwatch reports and extracts the failed assertion', () => {
  assert.deepEqual(summarizeNightwatchReports(reports), {
    suites: { passed: 0, failed: 1, total: 1 },
    cases: { passed: 1, failed: 1, skipped: 0, total: 2 },
    assertions: { passed: 4, failed: 1, skipped: 0, total: 5 },
    durationSeconds: 65.4,
    failures: [{
      suite: 'poll',
      test: 'edits a time poll',
      message: 'Element <.poll-common-card> was not visible'
    }]
  });
});

test('puts failure details before aggregate counts in the GitHub summary', () => {
  const markdown = renderNightwatchSummary(summarizeNightwatchReports(reports));

  assert.ok(markdown.indexOf('## Failures') < markdown.indexOf('## Summary'));
  assert.match(markdown, /`poll` \| `edits a time poll` \| Element <\.poll-common-card> was not visible/);
  assert.match(markdown, /\| Spec files \| 0 \| 1 \| — \| 1 \|/);
  assert.match(markdown, /Duration: 1m 5s/);
});

test('shows specs that fail before a testcase starts', () => {
  const summary = summarizeNightwatchReports([{
    name: 'signing_in',
    report: {
      completed: {},
      lastError: { detailedErr: ' ChromeDriver could not start ' }
    }
  }]);

  assert.deepEqual(summary.failures, [{
    suite: 'signing_in',
    test: 'Spec setup',
    message: 'ChromeDriver could not start'
  }]);
  assert.match(renderNightwatchSummary(summary), /`signing_in` \| `Spec setup` \| ChromeDriver could not start/);
});
