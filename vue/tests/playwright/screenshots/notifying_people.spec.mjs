import { test, expect } from '../screenshotFixtures.mjs';

import richText from '../helpers/oatmilkRichText.mjs';

async function openNewDiscussionForm(page) {
  await page.loadPath('setup_manual_oatmilk_new_discussion');
  await page.click('.discussions-panel__new-topic-button');
  await page.waitFor('.discussion-templates--template');
  await page.click('.discussion-templates--template-blank');
  await page.waitFor('.discussion-form');
  await page.waitFor('.recipients-autocomplete');
}

async function removeDefaultAudience(page) {
  await page.execute("document.querySelector('.recipients-autocomplete .v-chip__close').click()");
  await page.execute("document.querySelector('.recipients-autocomplete .announcement-form__input').scrollIntoView({block: 'center'})");
  await page.pause(200);
}

async function openDiscussion(page) {
  await page.loadPath('setup_manual_oatmilk_discussion');
  await page.waitFor('.topic-page');
  await page.expectText('.topic-page', 'Returnable bottles for cafe customers');
  await page.waitFor('.comment-form .ProseMirror');
  await page.pause(1000);
}

async function openMentionDiscussion(page) {
  await page.resizeWindow(1000, 1200);
  await page.loadPath('setup_manual_oatmilk_discussion_intro');
  await page.waitFor('.topic-page');
  await page.expectText('.topic-page', 'Improve the cafe bottle return process');
  await page.waitFor('.comment-form .ProseMirror');
  await page.pause(1000);
}

async function prepareDiscussionEdit(page) {
  await openDiscussion(page);
  await page.click('.context-panel .action-dock__button--edit_thread');
  await page.waitFor('.discussion-form');
  await page.fillIn(
    '.discussion-form .common-notify-fields .v-text-field input',
    'Added cafe collection details and clarified the proposed trial.'
  );
  await page.click('.discussion-form .recipients-autocomplete input[type="text"]');
  await page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
  await page.click('.v-overlay--active .recipients-autocomplete-suggestion--topic');
  await page.click('.discussion-form .common-notify-fields .v-text-field input');
}

async function postMentionComment(page) {
  await openDiscussion(page);
  await page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'Could you confirm the cafe collection dates, @samira');
  await page.waitForPresent('.suggestion-list [data-mention-handle="samirapatel"] .v-list-item-title');
  await page.clickElement('.suggestion-list [data-mention-handle="samirapatel"] .v-list-item-title');
  await page.click('.comment-form__submit-button');
  await page.pause(800);
  await page.expectText('.topic-page', 'Could you confirm the cafe collection dates');
  await page.execute("Array.from(document.querySelectorAll('.new-comment')).find(el => el.textContent.includes('Could you confirm the cafe collection dates')).classList.add('manual-mention-comment')");
}

async function revealPoll(page) {
  await openDiscussion(page);
  await page.execute("document.querySelector('.topic-item__load-more button')?.click()");
  await page.waitFor('.poll-created');
}

test('notification_recipients', async ({ lmo: page, manual: screenshot }) => {
  await openNewDiscussionForm(page);
  await page.execute("document.querySelector('.recipients-autocomplete .chip--select-multi').click()");
  await page.expectText('.recipients-autocomplete', 'Samira Patel');
  await page.expectText('.recipients-autocomplete', 'Alex Morgan');
  await screenshot.captureElement('discussions/notifying_people/thread_notification', '.discussion-form', {
    width: 1000,
    height: 1600,
    spotlight: {
      selector: '.discussion-form .recipients-autocomplete',
      padding: 10,
      radius: 12
    }
  });
});

test('notify_member_search', async ({ lmo: page, manual: screenshot }) => {
  await openNewDiscussionForm(page);
  await removeDefaultAudience(page);
  await page.fillIn('.recipients-autocomplete .announcement-form__input input', 'Sam');
  await page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
  await page.expectText('.v-overlay--active .recipients-autocomplete-suggestion', 'Samira Patel');
  await page.execute("document.querySelector('.discussion-form__submit').style.visibility = 'hidden'");
  await screenshot.captureRegion('discussions/notifying_people/thread_notify_user', [
    '.discussion-form',
    '.v-overlay--active .v-list'
  ], {
    padding: 16,
    width: 1000,
    height: 1800,
    spotlight: {selector: '.v-overlay--active .recipients-autocomplete-suggestion', padding: 8, radius: 12}
  });
});

test('notify_guest_email', async ({ lmo: page, manual: screenshot }) => {
  await openNewDiscussionForm(page);
  await removeDefaultAudience(page);
  await page.fillIn('.recipients-autocomplete .announcement-form__input input', 'guest@cafecircle.example');
  await page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
  await page.expectText('.v-overlay--active .recipients-autocomplete-suggestion', 'guest@cafecircle.example');
  await page.execute("document.querySelector('.discussion-form__submit').style.visibility = 'hidden'");
  await screenshot.captureRegion('discussions/notifying_people/thread_notify_email', [
    '.discussion-form',
    '.v-overlay--active .v-list'
  ], {
    padding: 16,
    width: 1000,
    height: 1800,
    spotlight: {selector: '.v-overlay--active .recipients-autocomplete-suggestion', padding: 8, radius: 12}
  });
});

test('mention_member', async ({ lmo: page, manual: screenshot }) => {
  await openMentionDiscussion(page);
  await page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'Could you confirm the collection schedule, @samira');
  await page.waitForPresent('.suggestion-list [data-mention-handle="samirapatel"] .v-list-item-title');
  await page.clickElement('.suggestion-list [data-mention-handle="samirapatel"] .v-list-item-title');
  await screenshot.captureRegion(
    'discussions/notifying_people/comment_mention',
    ['.comment-form'],
    {width: 1000, height: 1200, padding: 16}
  );
});

test('mention_group_search', async ({ lmo: page, manual: screenshot }) => {
  await openMentionDiscussion(page);
  await page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'Packaging update for @Oat');
  await page.waitForPresent('.suggestion-list .v-list-item');
  await screenshot.captureRegion('discussions/notifying_people/mentioning_group_1', [
    '.comment-form',
    '.suggestion-list'
  ], {padding: 16, width: 1000, height: 1200});
});

test('mention_group_selected', async ({ lmo: page, manual: screenshot }) => {
  await openMentionDiscussion(page);
  await page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'Packaging update for @Oat');
  await page.waitForPresent('.suggestion-list .v-list-item');
  await page.execute("Array.from(document.querySelectorAll('.suggestion-list .v-list-item')).find(el => el.textContent.includes('Oatmilk Cooperative')).click()");
  await page.expectText('.comment-form', 'Oatmilk Cooperative');
  await screenshot.captureRegion(
    'discussions/notifying_people/mentioning_group_2',
    ['.comment-form'],
    {width: 1000, height: 1200, padding: 16}
  );
});

test('reaction', async ({ lmo: page, manual: screenshot }) => {
  await page.resizeWindow(1100, 1400);
  await page.loadPath('setup_manual_oatmilk_discussion_intro');
  await page.waitFor('.topic-page');
  await page.expectText('.topic-page', 'Improve the cafe bottle return process');
  await page.waitFor('.topic-new-discussion .emoji-picker__toggle');
  await page.click('.topic-new-discussion .emoji-picker__toggle');
  await page.waitFor('.emoji-picker');
  await page.execute(`
    document.querySelector('.v-app-bar')?.remove();
    document.querySelector('.topic-sidebar')?.style.setProperty('visibility', 'hidden');
    document.querySelector('.actions-panel')?.style.setProperty('visibility', 'hidden');
    document.querySelectorAll('.topic-item__gutter').forEach((gutter) => {
      gutter.style.visibility = 'hidden';
    });
    document.querySelectorAll('.topic-item__intersection-container').forEach((item) => {
      if (!item.querySelector('.topic-new-discussion')) item.style.visibility = 'hidden';
    });
  `);
  await screenshot.captureRegion('discussions/notifying_people/reaction', [
    '.topic-new-discussion',
    '.emoji-picker'
  ], {
    padding: 32,
    width: 1100,
    height: 1400,
    includeThreadGutters: true
  });
});

test('thread_invite_icon', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.waitFor('.topic-sidebar .action-dock__button--announce_thread');
  await screenshot.capture('discussions/notifying_people/thread_invite_icon', {
    spotlight: {
      selector: '.topic-sidebar .action-dock__button--announce_thread',
      padding: 12,
      radius: 14
    },
    scrollSelector: '.topic-sidebar .action-dock__button--announce_thread',
    width: 1280,
    height: 1000
  });
});

test('thread_invite', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.click('.topic-sidebar .action-dock__button--announce_thread');
  await page.waitFor('.topic-members-list');
  await page.execute("document.querySelector('.topic-members-list > .v-list').style.display = 'none'");
  await screenshot.captureElement('discussions/notifying_people/thread_invite', '.topic-members-list', {
    width: 1100,
    height: 1200
  });
});

test('invite_guest', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.click('.topic-sidebar .action-dock__button--announce_thread');
  await page.waitFor('.topic-members-list');
  await page.fillIn('.topic-members-list .recipients-autocomplete input[type="text"]', 'guest@cafecircle.example');
  await page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
  await page.click('.v-overlay--active .recipients-autocomplete-suggestion');
  await page.waitFor('.topic-members-list textarea');
  await page.click('.topic-members-list textarea');
  await page.execute("document.querySelector('.topic-members-list > .v-list').style.display = 'none'");
  await screenshot.captureElement('discussions/notifying_people/invite_guest', '.topic-members-list', {
    width: 1100,
    height: 1200
  });
});

test('thread_edit_context', async ({ lmo: page, manual: screenshot }) => {
  await prepareDiscussionEdit(page);
  await screenshot.captureElement('discussions/notifying_people/thread_editcontext', '.discussion-form', {
    width: 1100,
    height: 1500
  });
});

test('thread_edit_comment', async ({ lmo: page, manual: screenshot }) => {
  await prepareDiscussionEdit(page);
  await page.fillRichText('.discussion-form .lmo-textarea [contenteditable=true]', richText.context('notified-thread-edit', [
    'Several cafe customers have asked whether we can supply oat milk in returnable glass bottles.',
    'Use this thread to compare collection dates, bottle deposits, washing checks, and responsibilities for the trial.',
    'We will record return rates, cleaning time, damaged bottles, and transport costs before reviewing the result.'
  ]));
  await page.click('.discussion-form__submit');
  await page.waitFor('.topic-item__discussion-edited');
  await page.expectText('.topic-item__discussion-edited', 'edited the thread context');
  await page.execute(`
    const target = document.querySelector('.topic-item__discussion-edited');
    document.querySelector('.v-app-bar')?.remove();
    document.querySelector('.actions-panel')?.style.setProperty('visibility', 'hidden');
    document.querySelectorAll('.topic-item__intersection-container').forEach((item) => {
      if (!item.contains(target)) item.style.visibility = 'hidden';
    });
  `);
  await screenshot.captureRegion(
    'discussions/notifying_people/thread_edit_comment',
    ['.topic-item__discussion-edited'],
    {
      width: 1100,
      height: 1200,
      padding: 16,
      includeThreadGutters: true,
      scrollSelector: '.topic-item__discussion-edited'
    }
  );
});

test('thread_engagement', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.waitFor('.topic-sidebar .action-dock__button--seen_by');
  await page.waitFor('.topic-sidebar .action-dock__button--users_notified');
  await screenshot.capture('discussions/notifying_people/thread_engagement', {
    spotlight: {
      selectors: [
        '.topic-sidebar .action-dock__button--seen_by',
        '.topic-sidebar .action-dock__button--users_notified'
      ],
      padding: 12,
      radius: 14
    },
    width: 1280,
    height: 1000
  });
});

test('thread_seen_by', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.click('.topic-sidebar .action-dock__button--seen_by');
  await page.waitFor('.v-overlay--active .v-card');
  await page.expectText('.v-overlay--active .v-card', 'Seen by');
  await page.expectText('.v-overlay--active .v-card', 'Jamie Chen');
  await screenshot.captureElement('discussions/notifying_people/thread_seenby', '.v-overlay--active .v-card', {
    width: 1100,
    height: 1000
  });
});

test('thread_notified', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.click('.topic-sidebar .action-dock__button--users_notified');
  await page.waitFor('.v-overlay--active .v-card');
  await page.expectText('.v-overlay--active .v-card', 'Thread notification history');
  await screenshot.captureElement('discussions/notifying_people/thread_notified', '.v-overlay--active .v-card', {
    width: 1100,
    height: 1200
  });
});

test('thread_notification_history', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.waitFor('.topic-sidebar .action-dock__button--users_notified');
  await screenshot.capture('discussions/notifying_people/thread_notification_history', {
    spotlight: {
      selector: '.topic-sidebar .action-dock__button--users_notified',
      padding: 12,
      radius: 14
    },
    width: 1280,
    height: 1000
  });
});

test('comment_notification_history', async ({ lmo: page, manual: screenshot }) => {
  await postMentionComment(page);
  await page.execute("document.querySelector('.flash-root')?.remove()");
  await page.click('.manual-mention-comment .action-menu');
  await page.waitFor('.v-overlay--active .action-dock__button--notification_history');
  await screenshot.capture('discussions/notifying_people/comment_notification_history', {
    spotlight: {
      selector: '.v-overlay--active .action-dock__button--notification_history',
      padding: 12,
      radius: 14
    },
    scrollSelector: '.manual-mention-comment',
    width: 1200,
    height: 1000
  });
});

test('comment_notification_example', async ({ lmo: page, manual: screenshot }) => {
  await postMentionComment(page);
  await page.execute("document.querySelector('.flash-root')?.remove()");
  await page.click('.manual-mention-comment .action-menu');
  await page.execute("document.querySelector('.v-overlay--active .action-dock__button--notification_history').click()");
  await page.waitFor('.v-overlay--active .v-card');
  await page.expectText('.v-overlay--active .v-card', 'Comment notification history');
  await page.expectText('.v-overlay--active .v-card', 'Samira Patel');
  await screenshot.captureElement('discussions/notifying_people/comment_notification_example', '.v-overlay--active .v-card', {
    width: 1100,
    height: 1000
  });
});

test('poll_notification_history', async ({ lmo: page, manual: screenshot }) => {
  await revealPoll(page);
  await page.click('.poll-created .action-menu');
  await page.waitFor('.v-overlay--active .action-dock__button--notification_history');
  await screenshot.capture('discussions/notifying_people/poll_notification_history', {
    spotlight: {
      selector: '.v-overlay--active .action-dock__button--notification_history',
      padding: 12,
      radius: 14
    },
    scrollSelector: '.poll-created',
    width: 1200,
    height: 1100
  });
});

test('poll_notification_example', async ({ lmo: page, manual: screenshot }) => {
  await revealPoll(page);
  await page.click('.poll-created .action-menu');
  await page.execute("document.querySelector('.v-overlay--active .action-dock__button--notification_history').click()");
  await page.waitFor('.v-overlay--active .v-card');
  await page.expectText('.v-overlay--active .v-card', 'Poll notification history');
  await page.expectText('.v-overlay--active .v-card', 'Samira Patel');
  await screenshot.captureElement('discussions/notifying_people/poll_notification_example', '.v-overlay--active .v-card', {
    width: 1100,
    height: 1000
  });
});

test('thread_interact', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.execute("document.querySelector('.topic-sidebar .topic-sidebar__notification-settings').classList.add('manual-volume-control')");
  await page.waitFor('.topic-sidebar .manual-volume-control');
  await screenshot.capture('discussions/notifying_people/thread_interact', {
    spotlight: {
      selector: '.topic-sidebar .manual-volume-control',
      padding: 12,
      radius: 14
    },
    width: 1280,
    height: 1000
  });
});
