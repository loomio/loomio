const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function openNewDiscussionForm(page) {
  page.loadPath('setup_manual_oatmilk_new_discussion');
  page.click('.discussions-panel__new-thread-button');
  page.waitFor('.discussion-templates--template');
  page.execute("Array.from(document.querySelectorAll('.discussion-templates--template')).find(el => el.textContent.includes('Blank')).click()");
  page.waitFor('.discussion-form');
  page.waitFor('.recipients-autocomplete');
}

function removeDefaultAudience(page) {
  page.execute("document.querySelector('.recipients-autocomplete .v-chip__close').click()");
  page.execute("document.querySelector('.recipients-autocomplete .announcement-form__input').scrollIntoView({block: 'center'})");
  page.pause(200);
}

function openDiscussion(page) {
  page.loadPath('setup_manual_oatmilk_discussion');
  page.waitFor('.strand-page');
  page.expectText('.strand-page', 'Returnable bottles for cafe customers');
  page.waitFor('.comment-form .ProseMirror');
}

function prepareDiscussionEdit(page) {
  openDiscussion(page);
  page.click('.context-panel .action-dock__button--edit_thread');
  page.waitFor('.discussion-form');
  page.fillIn(
    '.discussion-form .common-notify-fields .v-text-field input',
    'Added cafe collection details and clarified the proposed trial.'
  );
  page.click('.discussion-form .recipients-autocomplete input');
  page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
  page.execute("Array.from(document.querySelectorAll('.v-overlay--active .recipients-autocomplete-suggestion')).find(el => el.textContent.includes('Everyone in the thread')).click()");
  page.click('.discussion-form .common-notify-fields .v-text-field input');
}

function postMentionComment(page) {
  openDiscussion(page);
  page.fillIn('.comment-form .ProseMirror', 'Could you confirm the cafe collection dates, @samira');
  page.waitFor('.suggestion-list');
  page.click('.suggestion-list [data-mention-handle="samirapatel"] .v-list-item-title');
  page.click('.comment-form__submit-button');
  page.pause(800);
  page.expectText('.strand-page', 'Could you confirm the cafe collection dates');
  page.execute("Array.from(document.querySelectorAll('.new-comment')).find(el => el.textContent.includes('Could you confirm the cafe collection dates')).classList.add('manual-mention-comment')");
}

function revealPoll(page) {
  openDiscussion(page);
  page.click('.strand-item__load-more button');
  page.waitFor('.poll-created');
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'notification_recipients': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openNewDiscussionForm(page);
    page.execute("document.querySelector('.recipients-autocomplete .chip--select-multi').click()");
    page.expectText('.recipients-autocomplete', 'Samira Patel');
    page.expectText('.recipients-autocomplete', 'Alex Morgan');
    screenshot.captureElement('discussions/notifying_people/thread_notification', '.recipients-autocomplete', {
      width: 1000,
      height: 1000
    });
  },

  'notify_member_search': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openNewDiscussionForm(page);
    removeDefaultAudience(page);
    page.fillIn('.recipients-autocomplete .announcement-form__input input', 'Sam');
    page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
    page.expectText('.v-overlay--active .recipients-autocomplete-suggestion', 'Samira Patel');
    page.execute("document.querySelector('.discussion-form__submit').style.visibility = 'hidden'");
    screenshot.captureRegion('discussions/notifying_people/thread_notify_user', [
      '.recipients-autocomplete .announcement-form__input',
      '.v-overlay--active .v-list'
    ], {padding: 8, width: 1000, height: 1600});
  },

  'notify_guest_email': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openNewDiscussionForm(page);
    removeDefaultAudience(page);
    page.fillIn('.recipients-autocomplete .announcement-form__input input', 'guest@cafecircle.example');
    page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
    page.expectText('.v-overlay--active .recipients-autocomplete-suggestion', 'guest@cafecircle.example');
    page.execute("document.querySelector('.discussion-form__submit').style.visibility = 'hidden'");
    screenshot.captureRegion('discussions/notifying_people/thread_notify_email', [
      '.recipients-autocomplete .announcement-form__input',
      '.v-overlay--active .v-list'
    ], {padding: 8, width: 1000, height: 1600});
  },

  'mention_member': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    page.fillIn('.comment-form .ProseMirror', 'Could you confirm the collection schedule, @samira');
    page.waitFor('.suggestion-list');
    page.expectText('.suggestion-list', 'Samira Patel');
    page.click('.suggestion-list [data-mention-handle="samirapatel"] .v-list-item-title');
    screenshot.captureElement('discussions/notifying_people/comment_mention', '.comment-form .lmo-textarea', {
      width: 1000,
      height: 1200
    });
  },

  'mention_group_search': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    page.fillIn('.comment-form .ProseMirror', 'Packaging update for @Oat');
    page.waitFor('.suggestion-list');
    page.expectText('.suggestion-list', 'Oatmilk Cooperative');
    screenshot.captureRegion('discussions/notifying_people/mentioning_group_1', [
      '.comment-form .lmo-textarea',
      '.suggestion-list'
    ], {padding: 8, width: 1000, height: 1200});
  },

  'mention_group_selected': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    page.fillIn('.comment-form .ProseMirror', 'Packaging update for @Oat');
    page.waitFor('.suggestion-list');
    page.execute("Array.from(document.querySelectorAll('.suggestion-list .v-list-item')).find(el => el.textContent.includes('Oatmilk Cooperative')).click()");
    screenshot.captureElement('discussions/notifying_people/mentioning_group_2', '.comment-form .lmo-textarea', {
      width: 1000,
      height: 1200
    });
  },

  'reaction': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    page.waitFor('.strand-new-discussion .emoji-picker__toggle');
    screenshot.captureElement('discussions/notifying_people/reaction', '.strand-new-discussion', {
      spotlight: {
        selector: '.strand-new-discussion .emoji-picker__toggle',
        padding: 12,
        radius: 14
      },
      width: 1100,
      height: 1200
    });
  },

  'thread_invite_icon': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    page.waitFor('.thread-sidebar .action-dock__button--announce_thread');
    screenshot.capture('discussions/notifying_people/thread_invite_icon', {
      spotlight: {
        selector: '.thread-sidebar .action-dock__button--announce_thread',
        padding: 12,
        radius: 14
      },
      scrollSelector: '.thread-sidebar .action-dock__button--announce_thread',
      width: 1280,
      height: 1000
    });
  },

  'thread_invite': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    page.click('.thread-sidebar .action-dock__button--announce_thread');
    page.waitFor('.strand-members-list');
    page.execute("document.querySelector('.strand-members-list > .v-list').style.display = 'none'");
    screenshot.captureElement('discussions/notifying_people/thread_invite', '.strand-members-list', {
      width: 1100,
      height: 1200
    });
  },

  'invite_guest': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    page.click('.thread-sidebar .action-dock__button--announce_thread');
    page.waitFor('.strand-members-list');
    page.fillIn('.strand-members-list .recipients-autocomplete input', 'guest@cafecircle.example');
    page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
    page.click('.v-overlay--active .recipients-autocomplete-suggestion');
    page.waitFor('.strand-members-list textarea');
    page.click('.strand-members-list textarea');
    page.execute("document.querySelector('.strand-members-list > .v-list').style.display = 'none'");
    screenshot.captureElement('discussions/notifying_people/invite_guest', '.strand-members-list', {
      width: 1100,
      height: 1200
    });
  },

  'thread_edit_context': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    prepareDiscussionEdit(page);
    screenshot.captureElement('discussions/notifying_people/thread_editcontext', '.discussion-form', {
      width: 1100,
      height: 1500
    });
  },

  'thread_edit_comment': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    prepareDiscussionEdit(page);
    page.fillIn(
      '.discussion-form .lmo-textarea textarea',
      'Several cafe customers have asked about reusable packaging. Use this thread to share practical questions before we decide whether to run a trial. We will also record cleaning time and transport costs.'
    );
    page.click('.discussion-form__submit');
    page.waitFor('.strand-item__discussion-edited');
    page.expectText('.strand-item__discussion-edited', 'Added cafe collection details and clarified the proposed trial.');
    screenshot.captureElement(
      'discussions/notifying_people/thread_edit_comment',
      '.strand-item__discussion-edited',
      {width: 1100, height: 1200}
    );
  },

  'thread_engagement': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    page.waitFor('.thread-sidebar .action-dock__button--seen_by');
    page.waitFor('.thread-sidebar .action-dock__button--users_notified');
    screenshot.capture('discussions/notifying_people/thread_engagement', {
      spotlight: {
        selectors: [
          '.thread-sidebar .action-dock__button--seen_by',
          '.thread-sidebar .action-dock__button--users_notified'
        ],
        padding: 12,
        radius: 14
      },
      width: 1280,
      height: 1000
    });
  },

  'thread_seen_by': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    page.click('.thread-sidebar .action-dock__button--seen_by');
    page.waitFor('.v-overlay--active .v-card');
    page.expectText('.v-overlay--active .v-card', 'Seen by');
    page.expectText('.v-overlay--active .v-card', 'Jamie Chen');
    screenshot.captureElement('discussions/notifying_people/thread_seenby', '.v-overlay--active .v-card', {
      width: 1100,
      height: 1000
    });
  },

  'thread_notified': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    page.click('.thread-sidebar .action-dock__button--users_notified');
    page.waitFor('.v-overlay--active .v-card');
    page.expectText('.v-overlay--active .v-card', 'Thread notification history');
    screenshot.captureElement('discussions/notifying_people/thread_notified', '.v-overlay--active .v-card', {
      width: 1100,
      height: 1200
    });
  },

  'thread_notification_history': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    page.waitFor('.thread-sidebar .action-dock__button--users_notified');
    screenshot.capture('discussions/notifying_people/thread_notification_history', {
      spotlight: {
        selector: '.thread-sidebar .action-dock__button--users_notified',
        padding: 12,
        radius: 14
      },
      width: 1280,
      height: 1000
    });
  },

  'comment_notification_history': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    postMentionComment(page);
    page.execute("document.querySelector('.flash-root')?.remove()");
    page.click('.manual-mention-comment .action-menu');
    page.waitFor('.v-overlay--active .action-dock__button--notification_history');
    screenshot.capture('discussions/notifying_people/comment_notification_history', {
      spotlight: {
        selector: '.v-overlay--active .action-dock__button--notification_history',
        padding: 12,
        radius: 14
      },
      scrollSelector: '.manual-mention-comment',
      width: 1200,
      height: 1000
    });
  },

  'comment_notification_example': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    postMentionComment(page);
    page.execute("document.querySelector('.flash-root')?.remove()");
    page.click('.manual-mention-comment .action-menu');
    page.execute("document.querySelector('.v-overlay--active .action-dock__button--notification_history').click()");
    page.waitFor('.v-overlay--active .v-card');
    page.expectText('.v-overlay--active .v-card', 'Comment notification history');
    page.expectText('.v-overlay--active .v-card', 'Samira Patel');
    screenshot.captureElement('discussions/notifying_people/comment_notification_example', '.v-overlay--active .v-card', {
      width: 1100,
      height: 1000
    });
  },

  'poll_notification_history': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    revealPoll(page);
    page.click('.poll-created .action-menu');
    page.waitFor('.v-overlay--active .action-dock__button--notification_history');
    screenshot.capture('discussions/notifying_people/poll_notification_history', {
      spotlight: {
        selector: '.v-overlay--active .action-dock__button--notification_history',
        padding: 12,
        radius: 14
      },
      scrollSelector: '.poll-created',
      width: 1200,
      height: 1100
    });
  },

  'poll_notification_example': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    revealPoll(page);
    page.click('.poll-created .action-menu');
    page.execute("document.querySelector('.v-overlay--active .action-dock__button--notification_history').click()");
    page.waitFor('.v-overlay--active .v-card');
    page.expectText('.v-overlay--active .v-card', 'Poll notification history');
    page.expectText('.v-overlay--active .v-card', 'Samira Patel');
    screenshot.captureElement('discussions/notifying_people/poll_notification_example', '.v-overlay--active .v-card', {
      width: 1100,
      height: 1000
    });
  },

  'thread_interact': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    page.execute("Array.from(document.querySelectorAll('.thread-sidebar .v-list-item')).find(el => el.textContent.includes('Email when notified') || el.textContent.includes('Email notifications')).classList.add('manual-volume-control')");
    page.waitFor('.thread-sidebar .manual-volume-control');
    screenshot.capture('discussions/notifying_people/thread_interact', {
      spotlight: {
        selector: '.thread-sidebar .manual-volume-control',
        padding: 12,
        radius: 14
      },
      width: 1280,
      height: 1000
    });
  }
};
