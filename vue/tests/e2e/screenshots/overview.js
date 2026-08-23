const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function openGroup(page) {
  page.loadPath('setup_manual_oatmilk_group');
  page.waitFor('.group-page');
}

function openDiscussion(page) {
  page.loadPath('setup_manual_oatmilk_discussion');
  page.waitFor('.topic-page');
  page.waitFor('.topic-sidebar .action-dock__button--seen_by');
  page.pause(1000);
}

function openCommentDiscussion(page) {
  page.loadPath('setup_manual_oatmilk_comment_discussion');
  page.waitFor('.topic-page');
  page.expectText('.topic-page', 'Improve the cafe bottle collection process');
  page.waitFor('#add-comment .comment-form .ProseMirror');
}

function openProposal(page, mode) {
  page.loadPath(`setup_manual_oatmilk_proposal_template_poll?template=majority${mode ? `&mode=${mode}` : ''}`);
  page.waitFor('.poll-common-card__title');
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'group_example': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openGroup(page);
    screenshot.captureElement('overview/group_example', '.group-page', {width: 1280, height: 2000});
  },

  'orientation_group': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openGroup(page);
    screenshot.captureRegion('overview/orientation_group', [
      '.group-page .v-img',
      '.group-page__name',
      '.group-page__description',
      '.group-page .v-tabs'
    ], {width: 1100, height: 900, padding: 16});
  },

  'orientation_discussion': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_discussion_intro');
    page.waitFor('.topic-card');
    screenshot.captureRegion('overview/orientation_discussion', [
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
  },

  'orientation_proposal': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openDiscussion(page);
    screenshot.captureRegion('overview/orientation_proposal', [
      '.poll-common-card__title',
      '.poll-common-details-panel__details',
      '.poll-common-action-panel'
    ], {width: 1100, height: 1900, padding: 12, includeThreadGutters: true});
  },

  'sidebar': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openGroup(page);
    page.clickAndWait('.navbar__sidenav-toggle', '.sidenav-left');
    screenshot.captureElement('overview/sidebar', '.sidenav-left', {width: 1100, height: 1700});
  },

  'user_settings_sidebar': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openGroup(page);
    page.clickAndWait('.navbar__sidenav-toggle', '.sidenav-left');
    page.clickAndWait('.sidebar__user-dropdown', '.sidebar-close-settings');
    screenshot.captureElement('overview/user_settings_sidebar', '.sidenav-left', {width: 1100, height: 1700});
  },

  'in_app_notifications': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_notifications');
    page.clickAndWait('.notifications__button', '.notifications__dropdown');
    page.expectText('.notifications__dropdown', 'mentioned you');
    page.expectText('.notifications__dropdown', 'invited you to vote');
    page.expectText('.notifications__dropdown', 'started a discussion');
    screenshot.captureRegion('users/email_settings/in_app_notifications', ['.notifications__button', '.notifications__dropdown'], {
      width: 1100,
      height: 900,
      padding: 16
    });
  },

  'global_search': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openGroup(page);
    screenshot.capture('overview/search_button', {
      width: 1280,
      height: 900,
      spotlight: {
        selector: '.v-app-bar button[title="Search"]',
        padding: 10,
        radius: 24
      }
    });
    page.clickAndWait('.v-app-bar button[title="Search"]', '.search-modal');
    page.waitFor('.search-modal');
    page.fillInAndEnter('.search-modal input', 'bottle');
    page.pause(500);
    screenshot.captureElement('overview/search_strategy', '.search-modal', {width: 1100, height: 1600});
  },

  'tags': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_tags');
    page.waitFor('.tags-filter-menu__button');
    page.clickAndWait('.tags-filter-menu__button', '.tags-filter-menu__card');
    screenshot.captureRegion('overview/tags', ['.tags-filter-menu__button', '.tags-filter-menu__card'], {
      width: 1100,
      height: 1200,
      padding: 16
    });
  },

  'comment_add': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openCommentDiscussion(page);
    page.fillIn('#add-comment .comment-form .ProseMirror', 'I can help document the cleaning time during the trial.');
    screenshot.captureElement('overview/comment_add', '.topic-card', {
      width: 1100,
      height: 1600,
      spotlight: {selector: '#add-comment .comment-form', padding: 12, radius: 14}
    });
  },

  'comment_reply': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openCommentDiscussion(page);
    page.clickAndWait('.new-comment .action-dock__button--reply_to_comment', '.reply-form .comment-form');
    screenshot.captureRegion('overview/comment_reply', ['.new-comment', '.reply-form .comment-form'], {width: 1100, height: 1400, padding: 16});
  },

  'comment_mention': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openCommentDiscussion(page);
    page.fillIn('#add-comment .comment-form .lmo-textarea div[contenteditable=true]', 'Could you confirm the cafe collection dates, @samira');
    page.waitForPresent('.suggestion-list [data-mention-handle="samirapatel"] .v-list-item-title');
    page.clickElement('.suggestion-list [data-mention-handle="samirapatel"] .v-list-item-title');
    screenshot.captureElement('overview/comment_mention', '#add-comment .comment-form .lmo-textarea', {width: 1100, height: 1100});
  },

  'comment_reaction': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openCommentDiscussion(page);
    page.waitFor('.new-comment .emoji-picker__toggle');
    page.click('.new-comment .emoji-picker__toggle');
    page.waitFor('.v-overlay--active .emoji-picker');
    screenshot.captureRegion('overview/comment_reaction', [
      '.new-comment',
      '.v-overlay--active .emoji-picker'
    ], {
      width: 1100,
      height: 1400,
      padding: 24,
      spotlight: {selector: '.new-comment .emoji-picker__toggle', padding: 10, radius: 12}
    });
  },

  'proposal_example': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openProposal(page);
    screenshot.captureRegion('overview/proposal_example', ['.poll-common-card__title', '.poll-common-action-panel'], {width: 1100, height: 2200, padding: 16});
  },

  'vote_reason': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openProposal(page);
    screenshot.captureRegion('overview/vote_reason', ['.poll-common-vote-form'], {
      width: 1100,
      height: 1600,
      padding: 16,
      includeThreadGutters: false
    });
  },

  'vote_change': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openProposal(page, 'results');
    page.waitFor('.poll-common-current-vote .action-button');
    screenshot.captureRegion('overview/vote_change', ['.poll-created'], {
      width: 1100,
      height: 2000,
      padding: 16,
      spotlight: {selector: '.poll-common-current-vote .action-button', padding: 10, radius: 12}
    });
  },

  'vote_edit': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openProposal(page, 'results');
    page.clickAndWait('.poll-common-current-vote .action-button', '.poll-common-edit-vote-modal');
    screenshot.captureElement('overview/vote_edit', '.poll-common-edit-vote-modal', {width: 1100, height: 1800});
  },

  'proposal_results': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openProposal(page, 'results');
    page.waitFor('.poll-common-chart-panel');
    screenshot.captureRegion('overview/proposal_results', ['.poll-common-card__title', '.poll-common-chart-panel'], {width: 1100, height: 2200, padding: 16});
  },

  'proposal_outcome': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openProposal(page, 'outcome');
    page.waitFor('.poll-common-outcome-panel');
    screenshot.captureRegion('overview/proposal_outcome', ['.poll-common-card__title', '.poll-common-outcome-panel'], {width: 1100, height: 1800, padding: 16});
  }
};
