const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');
const richText = require('../helpers/oatmilkRichText');

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
  page.pause(1000);
}

function openMentionDiscussion(page) {
  page.resizeWindow(1000, 1200);
  page.loadPath('setup_manual_oatmilk_discussion_intro');
  page.waitFor('.strand-page');
  page.expectText('.strand-page', 'Improve the cafe bottle return process');
  page.waitFor('.comment-form .ProseMirror');
  page.pause(1000);
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
  page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'Could you confirm the cafe collection dates, @samira');
  page.waitForPresent('.suggestion-list [data-mention-handle="samirapatel"] .v-list-item-title');
  page.clickElement('.suggestion-list [data-mention-handle="samirapatel"] .v-list-item-title');
  page.click('.comment-form__submit-button');
  page.pause(800);
  page.expectText('.strand-page', 'Could you confirm the cafe collection dates');
  page.execute("Array.from(document.querySelectorAll('.new-comment')).find(el => el.textContent.includes('Could you confirm the cafe collection dates')).classList.add('manual-mention-comment')");
}

function revealPoll(page) {
  openDiscussion(page);
  page.execute("document.querySelector('.strand-item__load-more button')?.click()");
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
    screenshot.captureElement('discussions/notifying_people/thread_notification', '.discussion-form', {
      width: 1000,
      height: 1600,
      spotlight: {
        selector: '.discussion-form .recipients-autocomplete',
        padding: 10,
        radius: 12
      }
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
      '.discussion-form',
      '.v-overlay--active .v-list'
    ], {
      padding: 16,
      width: 1000,
      height: 1800,
      spotlight: {selector: '.v-overlay--active .recipients-autocomplete-suggestion', padding: 8, radius: 12}
    });
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
      '.discussion-form',
      '.v-overlay--active .v-list'
    ], {
      padding: 16,
      width: 1000,
      height: 1800,
      spotlight: {selector: '.v-overlay--active .recipients-autocomplete-suggestion', padding: 8, radius: 12}
    });
  },

  'mention_member': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openMentionDiscussion(page);
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'Could you confirm the collection schedule, @samira');
    page.waitForPresent('.suggestion-list [data-mention-handle="samirapatel"] .v-list-item-title');
    page.clickElement('.suggestion-list [data-mention-handle="samirapatel"] .v-list-item-title');
    screenshot.captureRegion(
      'discussions/notifying_people/comment_mention',
      ['.comment-form'],
      {width: 1000, height: 1200, padding: 16}
    );
  },

  'mention_group_search': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openMentionDiscussion(page);
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'Packaging update for @Oat');
    page.waitForPresent('.suggestion-list .v-list-item');
    screenshot.captureRegion('discussions/notifying_people/mentioning_group_1', [
      '.comment-form',
      '.suggestion-list'
    ], {padding: 16, width: 1000, height: 1200});
  },

  'mention_group_selected': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openMentionDiscussion(page);
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'Packaging update for @Oat');
    page.waitForPresent('.suggestion-list .v-list-item');
    page.execute("Array.from(document.querySelectorAll('.suggestion-list .v-list-item')).find(el => el.textContent.includes('Oatmilk Cooperative')).click()");
    page.expectText('.comment-form', 'Oatmilk Cooperative');
    screenshot.captureRegion(
      'discussions/notifying_people/mentioning_group_2',
      ['.comment-form'],
      {width: 1000, height: 1200, padding: 16}
    );
  },

  'reaction': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.resizeWindow(1100, 1400);
    page.loadPath('setup_manual_oatmilk_discussion_intro');
    page.waitFor('.strand-page');
    page.expectText('.strand-page', 'Improve the cafe bottle return process');
    page.waitFor('.strand-new-discussion .emoji-picker__toggle');
    page.click('.strand-new-discussion .emoji-picker__toggle');
    page.waitFor('.emoji-picker');
    page.execute(`
      document.querySelector('.v-app-bar')?.remove();
      document.querySelector('.thread-sidebar')?.style.setProperty('visibility', 'hidden');
      document.querySelector('.actions-panel')?.style.setProperty('visibility', 'hidden');
      document.querySelectorAll('.strand-item__gutter').forEach((gutter) => {
        gutter.style.visibility = 'hidden';
      });
      document.querySelectorAll('.strand-item__intersection-container').forEach((item) => {
        if (!item.querySelector('.strand-new-discussion')) item.style.visibility = 'hidden';
      });
    `);
    screenshot.captureRegion('discussions/notifying_people/reaction', [
      '.strand-new-discussion',
      '.emoji-picker'
    ], {
      padding: 32,
      width: 1100,
      height: 1400,
      includeThreadGutters: true
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
    page.fillRichText('.discussion-form .lmo-textarea [contenteditable=true]', richText.context('notified-thread-edit', [
      'Several cafe customers have asked whether we can supply oat milk in returnable glass bottles.',
      'Use this thread to compare collection dates, bottle deposits, washing checks, and responsibilities for the trial.',
      'We will record return rates, cleaning time, damaged bottles, and transport costs before reviewing the result.'
    ]));
    page.click('.discussion-form__submit');
    page.waitFor('.strand-item__discussion-edited');
    page.expectText('.strand-item__discussion-edited', 'Added cafe collection details and clarified the proposed trial.');
    page.execute(`
      const target = document.querySelector('.strand-item__discussion-edited');
      document.querySelector('.v-app-bar')?.remove();
      document.querySelector('.actions-panel')?.style.setProperty('visibility', 'hidden');
      document.querySelectorAll('.strand-item__intersection-container').forEach((item) => {
        if (!item.contains(target)) item.style.visibility = 'hidden';
      });
    `);
    screenshot.captureRegion(
      'discussions/notifying_people/thread_edit_comment',
      ['.strand-item__discussion-edited'],
      {
        width: 1100,
        height: 1200,
        padding: 16,
        includeThreadGutters: true,
        scrollSelector: '.strand-item__discussion-edited'
      }
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
