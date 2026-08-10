const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function openGroup(page) {
  page.loadPath('setup_manual_oatmilk_group');
  page.waitFor('.group-page');
}

function openDiscussion(page) {
  page.loadPath('setup_manual_oatmilk_discussion');
  page.waitFor('.strand-page');
  page.waitFor('.thread-sidebar .action-dock__button--seen_by');
  page.pause(1000);
}

function openProposal(page, mode) {
  page.loadPath(`setup_manual_oatmilk_proposal_template_poll?template=majority${mode ? `&mode=${mode}` : ''}`);
  page.waitFor('.poll-common-card__title');
}

function postOwnComment(page) {
  openDiscussion(page);
  page.fillIn('.comment-form .ProseMirror', 'I can document the cleaning time during the trial.');
  page.click('.comment-form__submit-button');
  page.pause(600);
  page.execute("Array.from(document.querySelectorAll('.new-comment')).find(el => el.textContent.includes('I can document the cleaning time')).classList.add('manual-own-comment')");
  page.waitFor('.manual-own-comment');
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'group_example': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openGroup(page);
    screenshot.captureElement('overview/group_example', '.group-page', {width: 1280, height: 2000});
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

  'notifications_demo': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_all_notifications');
    page.clickAndWait('.notifications__button', '.notifications__dropdown');
    screenshot.captureRegion('overview/notifications_demo', ['.notifications__button', '.notifications__dropdown'], {
      width: 1100,
      height: 1500,
      padding: 16
    });
  },

  'email_settings_full': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_email_settings');
    page.waitFor('.email-settings-page');
    screenshot.captureElement('overview/email_settings_full', '.email-settings-page', {width: 1100, height: 2600});
  },

  'search_strategy': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openGroup(page);
    page.execute("Array.from(document.querySelectorAll('.discussions-panel button')).find(el => el.textContent.includes('Search')).click()");
    page.waitFor('.search-modal');
    page.fillIn('.search-modal input', 'bottle');
    page.fillInAndEnter('.search-modal input', '');
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

  'discussion_example': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openDiscussion(page);
    screenshot.captureElement('overview/discussion_example', '.strand-page', {width: 1280, height: 2000});
  },

  'discussion_seen_by_example': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openDiscussion(page);
    page.clickAndWait('.thread-sidebar .action-dock__button--seen_by', '.v-overlay--active .v-card');
    screenshot.captureElement('overview/discussion_seen_by_example', '.v-overlay--active .v-card', {width: 1100, height: 1200});
  },

  'discussion_notification_example': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openDiscussion(page);
    page.clickAndWait('.thread-sidebar .action-dock__button--users_notified', '.v-overlay--active .v-card');
    screenshot.captureElement('overview/discussion_notification_example', '.v-overlay--active .v-card', {width: 1100, height: 1400});
  },

  'discussion_timeline_example': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openDiscussion(page);
    screenshot.captureRegion('overview/discussion_timeline_example', [
      '.thread-sidebar .v-list:first-child',
      '.thread-sidebar .v-list:last-child'
    ], {width: 1100, height: 1900, padding: 16});
  },

  'polls_tab': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openGroup(page);
    page.clickAndWait('.group-page-polls-tab', '.polls-panel');
    screenshot.captureRegion('overview/polls_tab', ['.group-page .v-tabs', '.polls-panel'], {
      width: 1280,
      height: 1800,
      padding: 16
    });
  },

  'comment_add': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openDiscussion(page);
    page.fillIn('.comment-form .ProseMirror', 'I can help document the cleaning time during the trial.');
    screenshot.captureElement('overview/comment_add', '.strand-card', {
      width: 1100,
      height: 1600,
      spotlight: {selector: '.comment-form', padding: 12, radius: 14}
    });
  },

  'comment_edit': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    postOwnComment(page);
    page.clickAndWait('.manual-own-comment .action-dock__button--edit_comment', '.edit-comment-form');
    screenshot.captureElement('overview/comment_edit', '.edit-comment-form', {width: 1100, height: 1200});
  },

  'comment_reply': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openDiscussion(page);
    page.clickAndWait('.new-comment .action-dock__button--reply_to_comment', '.reply-form .comment-form');
    screenshot.captureRegion('overview/comment_reply', ['.new-comment', '.reply-form .comment-form'], {width: 1100, height: 1400, padding: 16});
  },

  'comment_mention': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openDiscussion(page);
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'Could you confirm the cafe collection dates, @samira');
    page.waitForPresent('.suggestion-list [data-mention-handle="samirapatel"] .v-list-item-title');
    page.clickElement('.suggestion-list [data-mention-handle="samirapatel"] .v-list-item-title');
    screenshot.captureElement('overview/comment_mention', '.comment-form .lmo-textarea', {width: 1100, height: 1100});
  },

  'comment_reaction': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openDiscussion(page);
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
    screenshot.captureElement('overview/vote_reason', '.poll-common-vote-form', {width: 1100, height: 1600});
  },

  'vote_change': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openProposal(page, 'results');
    page.waitFor('.poll-common-current-vote .action-button');
    screenshot.captureElement('overview/vote_change', '.poll-created', {
      width: 1100,
      height: 2000,
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
  },

  'discussion_context_example': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openDiscussion(page);
    screenshot.captureElement('overview/discussion_context_example', '.context-panel', {width: 1100, height: 1500});
  },

  'discussion_comments_example': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openDiscussion(page);
    page.waitFor('.new-comment');
    screenshot.captureElement('overview/discussion_comments_example', '.strand-card', {width: 1100, height: 1800});
  }
};
