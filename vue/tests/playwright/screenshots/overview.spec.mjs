import { test, expect, expectLabel } from '../screenshotFixtures.mjs';
import { editor } from '../helpers/editor.mjs';
import { openSidebar } from '../helpers/groups.mjs';
import { comment, commentForm, mention } from '../helpers/threads.mjs';

// The first comment, which the capture selectors ('.new-comment') find.
const firstComment = page => comment(page, 'I can ask the cafe teams which collection days work best');

async function openGroup(page) {
  await page.goto('/dev/setup_manual_oatmilk_group');
  await expect(page.locator('.group-page')).toBeVisible();
}

async function openDiscussion(page) {
  await page.goto('/dev/setup_manual_oatmilk_discussion');
  await expect(page.locator('.topic-sidebar .action-dock__button--seen_by')).toBeVisible();
}

async function openCommentDiscussion(page) {
  await page.goto('/dev/setup_manual_oatmilk_comment_discussion');
  await expectLabel(page.locator('.topic-page'), 'Improve the cafe bottle collection process');
  await expect(editor(commentForm(page))).toBeVisible();
}

async function openProposal(page, mode) {
  await page.goto(`/dev/setup_manual_oatmilk_proposal_template_poll?template=majority${mode ? `&mode=${mode}` : ''}`);
  await expect(page.locator('.poll-common-card__title')).toBeVisible();
}

test('group_example', async ({ page, manual: screenshot }) => {
  await openGroup(page);
  await screenshot.captureElement('overview/group_example', '.group-page', {width: 1280, height: 2000});
});

test('orientation_group', async ({ page, manual: screenshot }) => {
  await openGroup(page);
  await screenshot.captureRegion('overview/orientation_group', [
    '.group-page .v-img',
    '.group-page__name',
    '.group-page__description',
    '.group-page .v-tabs'
  ], {width: 1100, height: 900, padding: 16});
});

test('orientation_discussion', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_discussion_intro');
  await expect(page.locator('.topic-card')).toBeVisible();
  await screenshot.captureRegion('overview/orientation_discussion', [
    '.topic-header',
    '.context-panel__description',
    '.new-comment'
  ], {
    width: 1100,
    height: 1500,
    padding: 24,
    scrollSelector: '.topic-card',
    scrollBlock: 'start'
  });
});

test('orientation_proposal', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await screenshot.captureRegion('overview/orientation_proposal', [
    '.poll-common-card__title',
    '.poll-common-details-panel__details',
    '.poll-common-action-panel'
  ], {width: 1100, height: 1900, padding: 12, includeThreadGutters: true});
});

test('sidebar', async ({ page, manual: screenshot }) => {
  await openGroup(page);
  await openSidebar(page);
  await screenshot.captureElement('overview/sidebar', '.sidenav-left', {width: 1100, height: 1700});
});

test('user_settings_sidebar', async ({ page, manual: screenshot }) => {
  await openGroup(page);
  await openSidebar(page);
  await page.locator('.sidebar__user-dropdown').click();
  await screenshot.captureElement('overview/user_settings_sidebar', '.sidenav-left', {width: 1100, height: 1700});
});

test('in_app_notifications', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_notifications');
  await page.locator('.notifications__button').click();
  await expectLabel(page.locator('.notifications__dropdown'), 'mentioned you');
  await expectLabel(page.locator('.notifications__dropdown'), 'invited you to vote');
  await expectLabel(page.locator('.notifications__dropdown'), 'started a discussion');
  await screenshot.captureRegion('users/email_settings/in_app_notifications', ['.notifications__button', '.notifications__dropdown'], {
    width: 1100,
    height: 900,
    padding: 16
  });
});

test('global_search', async ({ page, manual: screenshot }) => {
  await openGroup(page);
  await screenshot.capture('overview/search_button', {
    width: 1280,
    height: 900,
    spotlight: {
      selector: '.v-app-bar .navbar__search',
      padding: 10,
      radius: 24
    }
  });
  await page.locator('.v-app-bar .navbar__search').click();
  await page.locator('.search-modal__query input').fill('bottle');
  await page.locator('.search-modal__query input').press('Enter');
  await screenshot.captureElement('overview/search_strategy', '.search-modal', {width: 1100, height: 1600});
});

test('tags', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_tags');
  await page.locator('.tags-filter-menu__button').click();
  await screenshot.captureRegion('overview/tags', ['.tags-filter-menu__button', '.tags-filter-menu__card'], {
    width: 1100,
    height: 1200,
    padding: 16
  });
});

test('comment_add', async ({ page, manual: screenshot }) => {
  await openCommentDiscussion(page);
  await editor(commentForm(page)).fill('I can help document the cleaning time during the trial.');
  await screenshot.captureElement('overview/comment_add', '.topic-card', {
    width: 1100,
    height: 1600,
    spotlight: {selector: '#add-comment .comment-form', padding: 12, radius: 14}
  });
});

test('comment_reply', async ({ page, manual: screenshot }) => {
  await openCommentDiscussion(page);
  await firstComment(page).locator('.action-dock__button--reply_to_comment').click();
  await screenshot.captureRegion('overview/comment_reply', ['.new-comment', '.reply-form .comment-form'], {width: 1100, height: 1400, padding: 16});
});

test('comment_mention', async ({ page, manual: screenshot }) => {
  await openCommentDiscussion(page);
  await mention(page, editor(commentForm(page)), 'Could you confirm the cafe collection dates, @samira', 'samirapatel');
  await screenshot.captureElement('overview/comment_mention', '#add-comment .comment-form .lmo-textarea', {width: 1100, height: 1100});
});

test('comment_reaction', async ({ page, manual: screenshot }) => {
  await openCommentDiscussion(page);
  await firstComment(page).locator('.emoji-picker__toggle').click();
  await expect(page.locator('.v-overlay--active .emoji-picker')).toBeVisible();
  await screenshot.captureRegion('overview/comment_reaction', [
    '.new-comment',
    '.v-overlay--active .emoji-picker'
  ], {
    width: 1100,
    height: 1400,
    padding: 24,
    spotlight: {selector: '.new-comment .emoji-picker__toggle', padding: 10, radius: 12}
  });
});

test('proposal_example', async ({ page, manual: screenshot }) => {
  await openProposal(page);
  await screenshot.captureRegion('overview/proposal_example', ['.poll-common-card__title', '.poll-common-action-panel'], {width: 1100, height: 2200, padding: 16});
});

test('vote_reason', async ({ page, manual: screenshot }) => {
  await openProposal(page);
  await screenshot.captureRegion('overview/vote_reason', ['.poll-common-vote-form'], {
    width: 1100,
    height: 1600,
    padding: 16,
    includeThreadGutters: false
  });
});

test('vote_change', async ({ page, manual: screenshot }) => {
  await openProposal(page, 'results');
  await expect(page.locator('.poll-common-current-vote .action-button')).toBeVisible();
  await screenshot.captureRegion('overview/vote_change', ['.poll-created'], {
    width: 1100,
    height: 2000,
    padding: 16,
    spotlight: {selector: '.poll-common-current-vote .action-button', padding: 10, radius: 12}
  });
});

test('vote_edit', async ({ page, manual: screenshot }) => {
  await openProposal(page, 'results');
  await page.locator('.poll-common-current-vote .action-button').click();
  await screenshot.captureElement('overview/vote_edit', '.poll-common-edit-vote-modal', {width: 1100, height: 1800});
});

test('proposal_results', async ({ page, manual: screenshot }) => {
  await openProposal(page, 'results');
  await expect(page.locator('.poll-common-chart-panel')).toBeVisible();
  await screenshot.captureRegion('overview/proposal_results', ['.poll-common-card__title', '.poll-common-chart-panel'], {width: 1100, height: 2200, padding: 16});
});

test('proposal_outcome', async ({ page, manual: screenshot }) => {
  await openProposal(page, 'outcome');
  await expect(page.locator('.poll-common-outcome-panel')).toBeVisible();
  await screenshot.captureRegion('overview/proposal_outcome', ['.poll-common-card__title', '.poll-common-outcome-panel'], {width: 1100, height: 1800, padding: 16});
});
