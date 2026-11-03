import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

import richText from '../helpers/oatmilkRichText.mjs';

const workflows = [
  ['advice', 'proposal_advice'],
  ['consent', 'proposal_consent'],
  ['consensus', 'proposal_consensus'],
  ['check', 'proposal_sense_check'],
  ['gradients_of_agreement', 'proposal_gradients']
];

const defaultProposalDirectories = {
  advice: 'advice',
  consent: 'consent',
  consensus: 'consensus',
  check: 'sense_check'
};

const proposalTitles = {
  advice: 'Choose a bottle washing supplier',
  consent: 'Start the returnable bottle trial next month',
  consensus: 'Adopt the cooperative bottle return standard',
  check: 'Is the bottle trial plan ready for final review?'
};

async function loadForm(page, template) {
  await page.goto(`/dev/setup_manual_oatmilk_new_poll?poll_type=${template}`)
  await expect(page.locator('.poll-common-form').first()).toBeVisible()
  await page.locator('.poll-common-form-fields__title input').fill(proposalTitles[template])
  await page.locator('.poll-common-form-fields__details [contenteditable=true]').evaluate((editor, html) => {
    editor.focus()
    editor.innerHTML = html
    editor.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText' }))
  }, richText.context(`new-${template}-proposal`, [
      'Review the proposal and its supporting information before responding.',
      'Explain the practical experience, risk, or concern behind your response.',
      'The coordinator will publish an outcome that records what happens next.'
    ]))
}

async function loadPoll(page, template, mode) {
  await page.goto(`/dev/setup_manual_oatmilk_proposal_template_poll?template=${template}${mode ? `&mode=${mode}` : ''}`)
  await expect(page.locator('.poll-common-card__title').first()).toBeVisible()
}

async function captureVoting(screenshot, name) {
  await screenshot.captureRegion(
    `polls/proposals/${name}_voting`,
    ['.poll-common-card__title', '.poll-common-action-panel'],
    {width: 1100, height: 2200, padding: 16}
  );
}

async function captureResults(screenshot, name) {
  await screenshot.captureRegion(
    `polls/proposals/${name}_results`,
    ['.poll-common-card__title', '.poll-common-chart-panel'],
    {width: 1100, height: 2200, padding: 16}
  );
}

test('proposal_templates_list', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_formatting?key=0')
  await page.locator('.activity-panel__add-poll').click()
  await screenshot.captureElement('polls/proposals/proposal_templates_list', '.poll-common-templates-list', {width: 1100, height: 1400});
});

test('proposal_classic_voting', async ({ page, manual: screenshot }) => {
  await loadPoll(page, 'majority');
  await captureVoting(screenshot, 'proposal_classic');
});

test('proposal_question', async ({ page, manual: screenshot }) => {
  await loadPoll(page, 'question');
  await screenshot.captureRegion(
    'polls/proposals/proposal_question',
    ['.poll-common-card__title', '.poll-common-action-panel'],
    {width: 1100, height: 2200, padding: 16}
  );
});

workflows.forEach(([template, name]) => {
  if (defaultProposalDirectories[template]) {
    test(`${name}_form`, async ({ page, manual: screenshot }) => {
      await loadForm(page, template);
      await screenshot.captureElement(
        `polls/proposals/${defaultProposalDirectories[template]}/form`,
        '.poll-common-form',
        {width: 1100, height: 2600}
      );
    });
  }

  test(`${name}_voting`, async ({ page, manual: screenshot }) => {
    await loadPoll(page, template);
    await captureVoting(screenshot, name);
  });

  if (defaultProposalDirectories[template]) {
    test(`${name}_outcome`, async ({ page, manual: screenshot }) => {
      await loadPoll(page, template, 'outcome');
      await expect(page.locator('.poll-common-outcome-panel').first()).toBeVisible()
      await screenshot.captureRegion(
        `polls/proposals/${defaultProposalDirectories[template]}/outcome`,
        ['.poll-created .poll-common-card__title', '.poll-created .poll-common-chart-panel', '.poll-created .action-dock'],
        {
          padding: 32,
          width: 1200,
          height: 2200,
          clearSelection: true,
          spotlight: {selector: '.poll-common-outcome-panel', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}
        }
      );
    });
  }

  test(`${name}_results`, async ({ page, manual: screenshot }) => {
    await loadPoll(page, template, 'results');
    await expect(page.locator('.poll-common-chart-panel').first()).toBeVisible()
    await captureResults(screenshot, name);
  });
});

