import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const caseStatus = testCase => {
  if (testCase.status === 'pass') return 'passed';
  if (testCase.status === 'fail' || testCase.failed > 0 || testCase.errors > 0) return 'failed';
  return 'skipped';
};

const failureMessage = testCase => {
  const assertion = testCase.assertions?.find(item => item.failure);
  return assertion?.fullMsg || assertion?.message || testCase.stackTrace?.split('\n')[0] || 'No error message was reported';
};

const reportFailureMessage = error => error.message || error.detailedErr?.trim() || error.code || 'The spec failed before any testcase completed';

export const summarizeNightwatchReports = reports => {
  const summary = {
    suites: { passed: 0, failed: 0, total: reports.length },
    cases: { passed: 0, failed: 0, skipped: 0, total: 0 },
    assertions: { passed: 0, failed: 0, skipped: 0, total: 0 },
    durationSeconds: 0,
    failures: []
  };

  for (const { name, report } of reports) {
    const testCases = Object.entries(report.completed || {});
    const failedTestCases = testCases.filter(([, testCase]) => caseStatus(testCase) === 'failed');
    const suiteFailed = failedTestCases.length > 0 || Boolean(report.lastError);
    summary.suites[suiteFailed ? 'failed' : 'passed'] += 1;
    summary.durationSeconds += Number(report.time || 0);

    if (report.lastError && failedTestCases.length === 0) {
      summary.failures.push({ suite: name, test: 'Spec setup', message: reportFailureMessage(report.lastError) });
    }

    for (const [testName, testCase] of testCases) {
      const status = caseStatus(testCase);
      summary.cases[status] += 1;
      summary.cases.total += 1;
      summary.assertions.passed += Number(testCase.passed || 0);
      summary.assertions.failed += Number(testCase.failed || 0) + Number(testCase.errors || 0);
      summary.assertions.skipped += Number(testCase.skipped || 0);
      summary.assertions.total += Number(testCase.tests || 0);

      if (status === 'failed') {
        summary.failures.push({ suite: name, test: testName, message: failureMessage(testCase) });
      }
    }
  }

  return summary;
};

const duration = seconds => {
  const rounded = Math.round(seconds);
  const minutes = Math.floor(rounded / 60);
  const remainder = rounded % 60;
  return minutes ? `${minutes}m ${remainder}s` : `${remainder}s`;
};

const escapeTableCell = value => String(value).replaceAll('|', '\\|').replaceAll('\n', ' ');

export const renderNightwatchSummary = summary => {
  const lines = ['# Nightwatch E2E Test Report', ''];

  if (summary.failures.length) {
    lines.push('## Failures', '', '| Spec | Testcase | Failure |', '| --- | --- | --- |');
    for (const failure of summary.failures) {
      lines.push(`| \`${escapeTableCell(failure.suite)}\` | \`${escapeTableCell(failure.test)}\` | ${escapeTableCell(failure.message)} |`);
    }
    lines.push('');
  } else {
    lines.push('## All Nightwatch tests passed', '');
  }

  lines.push(
    '## Summary',
    '',
    '| | Passed | Failed | Skipped | Total |',
    '| --- | ---: | ---: | ---: | ---: |',
    `| Spec files | ${summary.suites.passed} | ${summary.suites.failed} | — | ${summary.suites.total} |`,
    `| Testcases | ${summary.cases.passed} | ${summary.cases.failed} | ${summary.cases.skipped} | ${summary.cases.total} |`,
    `| Assertions | ${summary.assertions.passed} | ${summary.assertions.failed} | ${summary.assertions.skipped} | ${summary.assertions.total} |`,
    '',
    `Duration: ${duration(summary.durationSeconds)}`,
    ''
  );

  return lines.join('\n');
};

export const loadNightwatchReports = directory => fs.readdirSync(directory)
  .filter(filename => filename.endsWith('.json'))
  .map(filename => JSON.parse(fs.readFileSync(path.join(directory, filename), 'utf8')))
  .filter(result => result.report);

const run = () => {
  const reportsDirectory = path.resolve('tests/reports');
  const reports = fs.existsSync(reportsDirectory) ? loadNightwatchReports(reportsDirectory) : [];
  const markdown = reports.length
    ? renderNightwatchSummary(summarizeNightwatchReports(reports))
    : '# Nightwatch E2E Test Report\n\nNo Nightwatch reports were generated.\n';

  if (process.env.GITHUB_STEP_SUMMARY) {
    fs.appendFileSync(process.env.GITHUB_STEP_SUMMARY, markdown);
  } else {
    process.stdout.write(markdown);
  }
};

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) run();
