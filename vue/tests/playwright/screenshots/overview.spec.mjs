import { test, expect } from '../screenshotFixtures.mjs';

async function openGroup(page) {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.waitFor('.group-page');
}

async function openDiscussion(page) {
  await page.loadPath('setup_manual_oatmilk_discussion');
  await page.waitFor('.topic-page');
  await page.waitFor('.topic-sidebar .action-dock__button--seen_by');
  await page.pause(1000);
}

async function openCommentDiscussion(page) {
  await page.loadPath('setup_manual_oatmilk_comment_discussion');
  await page.waitFor('.topic-page');
  await page.expectText('.topic-page', 'Improve the cafe bottle collection process');
  await page.waitFor('#add-comment .comment-form .ProseMirror');
}

async function openProposal(page, mode) {
  await page.loadPath(`setup_manual_oatmilk_proposal_template_poll?template=majority${mode ? `&mode=${mode}` : ''}`);
  await page.waitFor('.poll-common-card__title');
}

test('group_example', async ({ lmo: page, manual: screenshot }) => {
  await openGroup(page);
  await screenshot.captureElement('overview/group_example', '.group-page', {width: 1280, height: 2000});
});

test('orientation_group', async ({ lmo: page, manual: screenshot }) => {
  await openGroup(page);
  await screenshot.captureRegion('overview/orientation_group', [
    '.group-page .v-img',
    '.group-page__name',
    '.group-page__description',
    '.group-page .v-tabs'
  ], {width: 1100, height: 900, padding: 16});
});

test('orientation_discussion', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_discussion_intro');
  await page.waitFor('.topic-card');
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

test('orientation_proposal', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page);
  await screenshot.captureRegion('overview/orientation_proposal', [
    '.poll-common-card__title',
    '.poll-common-details-panel__details',
    '.poll-common-action-panel'
  ], {width: 1100, height: 1900, padding: 12, includeThreadGutters: true});
});

test('sidebar', async ({ lmo: page, manual: screenshot }) => {
  await openGroup(page);
  await page.clickAndWait('.navbar__sidenav-toggle', '.sidenav-left');
  await screenshot.captureElement('overview/sidebar', '.sidenav-left', {width: 1100, height: 1700});
});

test('user_settings_sidebar', async ({ lmo: page, manual: screenshot }) => {
  await openGroup(page);
  await page.clickAndWait('.navbar__sidenav-toggle', '.sidenav-left');
  await page.clickAndWait('.sidebar__user-dropdown', '.sidebar-close-settings');
  await screenshot.captureElement('overview/user_settings_sidebar', '.sidenav-left', {width: 1100, height: 1700});
});

test('in_app_notifications', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_notifications');
  await page.clickAndWait('.notifications__button', '.notifications__dropdown');
  await page.expectText('.notifications__dropdown', 'mentioned you');
  await page.expectText('.notifications__dropdown', 'invited you to vote');
  await page.expectText('.notifications__dropdown', 'started a discussion');
  await screenshot.captureRegion('users/email_settings/in_app_notifications', ['.notifications__button', '.notifications__dropdown'], {
    width: 1100,
    height: 900,
    padding: 16
  });
});

test('global_search', async ({ lmo: page, manual: screenshot }) => {
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
  await page.clickAndWait('.v-app-bar .navbar__search', '.search-modal');
  await page.waitFor('.search-modal');
  await page.fillInAndEnter('.search-modal input', 'bottle');
  await page.pause(500);
  await screenshot.captureElement('overview/search_strategy', '.search-modal', {width: 1100, height: 1600});
});

test('tags', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_tags');
  await page.waitFor('.tags-filter-menu__button');
  await page.clickAndWait('.tags-filter-menu__button', '.tags-filter-menu__card');
  await screenshot.captureRegion('overview/tags', ['.tags-filter-menu__button', '.tags-filter-menu__card'], {
    width: 1100,
    height: 1200,
    padding: 16
  });
});

test('comment_add', async ({ lmo: page, manual: screenshot }) => {
  await openCommentDiscussion(page);
  await page.fillIn('#add-comment .comment-form .ProseMirror', 'I can help document the cleaning time during the trial.');
  await screenshot.captureElement('overview/comment_add', '.topic-card', {
    width: 1100,
    height: 1600,
    spotlight: {selector: '#add-comment .comment-form', padding: 12, radius: 14}
  });
});

test('comment_reply', async ({ lmo: page, manual: screenshot }) => {
  await openCommentDiscussion(page);
  await page.clickAndWait('.new-comment .action-dock__button--reply_to_comment', '.reply-form .comment-form');
  await screenshot.captureRegion('overview/comment_reply', ['.new-comment', '.reply-form .comment-form'], {width: 1100, height: 1400, padding: 16});
});

test('comment_mention', async ({ lmo: page, manual: screenshot }) => {
  await openCommentDiscussion(page);
  await page.fillIn('#add-comment .comment-form .lmo-textarea div[contenteditable=true]', 'Could you confirm the cafe collection dates, @samira');
  await page.waitForPresent('.suggestion-list [data-mention-handle="samirapatel"] .v-list-item-title');
  await page.clickElement('.suggestion-list [data-mention-handle="samirapatel"] .v-list-item-title');
  await screenshot.captureElement('overview/comment_mention', '#add-comment .comment-form .lmo-textarea', {width: 1100, height: 1100});
});

test('comment_reaction', async ({ lmo: page, manual: screenshot }) => {
  await openCommentDiscussion(page);
  await page.waitFor('.new-comment .emoji-picker__toggle');
  await page.click('.new-comment .emoji-picker__toggle');
  await page.waitFor('.v-overlay--active .emoji-picker');
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

test('proposal_example', async ({ lmo: page, manual: screenshot }) => {
  await openProposal(page);
  await screenshot.captureRegion('overview/proposal_example', ['.poll-common-card__title', '.poll-common-action-panel'], {width: 1100, height: 2200, padding: 16});
});

test('vote_reason', async ({ lmo: page, manual: screenshot }) => {
  await openProposal(page);
  await screenshot.captureRegion('overview/vote_reason', ['.poll-common-vote-form'], {
    width: 1100,
    height: 1600,
    padding: 16,
    includeThreadGutters: false
  });
});

test('vote_change', async ({ lmo: page, manual: screenshot }) => {
  await openProposal(page, 'results');
  await page.waitFor('.poll-common-current-vote .action-button');
  await screenshot.captureRegion('overview/vote_change', ['.poll-created'], {
    width: 1100,
    height: 2000,
    padding: 16,
    spotlight: {selector: '.poll-common-current-vote .action-button', padding: 10, radius: 12}
  });
});

test('vote_edit', async ({ lmo: page, manual: screenshot }) => {
  await openProposal(page, 'results');
  await page.clickAndWait('.poll-common-current-vote .action-button', '.poll-common-edit-vote-modal');
  await screenshot.captureElement('overview/vote_edit', '.poll-common-edit-vote-modal', {width: 1100, height: 1800});
});

test('proposal_results', async ({ lmo: page, manual: screenshot }) => {
  await openProposal(page, 'results');
  await page.waitFor('.poll-common-chart-panel');
  await screenshot.captureRegion('overview/proposal_results', ['.poll-common-card__title', '.poll-common-chart-panel'], {width: 1100, height: 2200, padding: 16});
});

test('proposal_outcome', async ({ lmo: page, manual: screenshot }) => {
  await openProposal(page, 'outcome');
  await page.waitFor('.poll-common-outcome-panel');
  await screenshot.captureRegion('overview/proposal_outcome', ['.poll-common-card__title', '.poll-common-outcome-panel'], {width: 1100, height: 1800, padding: 16});
});
