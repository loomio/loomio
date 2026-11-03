import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

import richText from '../helpers/oatmilkRichText.mjs';

async function openNewDiscussionForm(page) {
  await page.goto('/dev/setup_manual_oatmilk_new_discussion')
  await page.locator('.discussions-panel__new-topic-button').click()
  await expect(page.locator('.discussion-templates--template').first()).toBeVisible()
  await page.locator('.discussion-templates--template-blank').click()
  await expect(page.locator('.discussion-form').first()).toBeVisible()
  await expect(page.locator('.recipients-autocomplete').first()).toBeVisible()
}

async function removeDefaultAudience(page) {
  await page.evaluate("document.querySelector('.recipients-autocomplete .v-chip__close').click()")
  await page.evaluate("document.querySelector('.recipients-autocomplete .announcement-form__input').scrollIntoView({block: 'center'})")
}

async function openDiscussion(page) {
  await page.goto('/dev/setup_manual_oatmilk_discussion')
  await expect(page.locator('.topic-page').first()).toBeVisible()
  await expectLabel(page.locator('.topic-page'), 'Returnable bottles for cafe customers')
  await expect(page.locator('.comment-form .ProseMirror').first()).toBeVisible()
}

async function openMentionDiscussion(page) {
  await page.setViewportSize({ width: 1000, height: 1200 })
  await page.goto('/dev/setup_manual_oatmilk_discussion_intro')
  await expect(page.locator('.topic-page').first()).toBeVisible()
  await expectLabel(page.locator('.topic-page'), 'Improve the cafe bottle return process')
  await expect(page.locator('.comment-form .ProseMirror').first()).toBeVisible()
}

async function prepareDiscussionEdit(page) {
  await openDiscussion(page);
  await page.locator('.context-panel .action-dock__button--edit_thread').click()
  await expect(page.locator('.discussion-form').first()).toBeVisible()
  await page.locator('.discussion-form .common-notify-fields .v-text-field input').fill('Added cafe collection details and clarified the proposed trial.')
  await page.locator('.discussion-form .recipients-autocomplete input[type="text"]').click()
  await expect(page.locator('.v-overlay--active .recipients-autocomplete-suggestion').first()).toBeVisible()
  await page.locator('.v-overlay--active .recipients-autocomplete-suggestion--topic').click()
  await page.locator('.discussion-form .common-notify-fields .v-text-field input').click()
}

async function postMentionComment(page) {
  await openDiscussion(page);
  await page.locator('.comment-form .lmo-textarea div[contenteditable=true]').pressSequentially('Could you confirm the cafe collection dates, @samira')
  await expect(page.locator('.suggestion-list [data-mention-handle="samirapatel"] .v-list-item-title').first()).toBeAttached()
  await page.locator('.suggestion-list [data-mention-handle="samirapatel"] .v-list-item-title').click()
  await page.locator('.comment-form__submit-button').click()
  await expectLabel(page.locator('.topic-page'), 'Could you confirm the cafe collection dates')
  await page.evaluate("Array.from(document.querySelectorAll('.new-comment')).find(el => el.textContent.includes('Could you confirm the cafe collection dates')).classList.add('manual-mention-comment')")
}

async function revealPoll(page) {
  await openDiscussion(page);
  await page.evaluate("document.querySelector('.topic-item__load-more button')?.click()")
  await expect(page.locator('.poll-created').first()).toBeVisible()
}

test('notification_recipients', async ({ page, manual: screenshot }) => {
  await openNewDiscussionForm(page);
  await page.evaluate("document.querySelector('.recipients-autocomplete .chip--select-multi').click()")
  await expectLabel(page.locator('.recipients-autocomplete'), 'Samira Patel')
  await expectLabel(page.locator('.recipients-autocomplete'), 'Alex Morgan')
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

test('notify_member_search', async ({ page, manual: screenshot }) => {
  await openNewDiscussionForm(page);
  await removeDefaultAudience(page);
  await page.locator('.recipients-autocomplete .announcement-form__input input').fill('Sam')
  await expect(page.locator('.v-overlay--active .recipients-autocomplete-suggestion').first()).toBeVisible()
  await expectLabel(page.locator('.v-overlay--active .recipients-autocomplete-suggestion'), 'Samira Patel')
  await page.evaluate("document.querySelector('.discussion-form__submit').style.visibility = 'hidden'")
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

test('notify_guest_email', async ({ page, manual: screenshot }) => {
  await openNewDiscussionForm(page);
  await removeDefaultAudience(page);
  await page.locator('.recipients-autocomplete .announcement-form__input input').pressSequentially('guest@cafecircle.example')
  await expect(page.locator('.v-overlay--active .recipients-autocomplete-suggestion').first()).toBeVisible()
  await expectLabel(page.locator('.v-overlay--active .recipients-autocomplete-suggestion'), 'guest@cafecircle.example')
  await page.evaluate("document.querySelector('.discussion-form__submit').style.visibility = 'hidden'")
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

test('mention_member', async ({ page, manual: screenshot }) => {
  await openMentionDiscussion(page);
  await page.locator('.comment-form .lmo-textarea div[contenteditable=true]').pressSequentially('Could you confirm the collection schedule, @samira')
  await expect(page.locator('.suggestion-list [data-mention-handle="samirapatel"] .v-list-item-title').first()).toBeAttached()
  await page.locator('.suggestion-list [data-mention-handle="samirapatel"] .v-list-item-title').click()
  await screenshot.captureRegion(
    'discussions/notifying_people/comment_mention',
    ['.comment-form'],
    {width: 1000, height: 1200, padding: 16}
  );
});

test('mention_group_search', async ({ page, manual: screenshot }) => {
  await openMentionDiscussion(page);
  await page.locator('.comment-form .lmo-textarea div[contenteditable=true]').pressSequentially('Packaging update for @Oat')
  await expect(page.locator('.suggestion-list .v-list-item').first()).toBeAttached()
  await screenshot.captureRegion('discussions/notifying_people/mentioning_group_1', [
    '.comment-form',
    '.suggestion-list'
  ], {padding: 16, width: 1000, height: 1200});
});

test('mention_group_selected', async ({ page, manual: screenshot }) => {
  await openMentionDiscussion(page);
  await page.locator('.comment-form .lmo-textarea div[contenteditable=true]').pressSequentially('Packaging update for @Oat')
  await expect(page.locator('.suggestion-list .v-list-item').first()).toBeAttached()
  await page.evaluate("Array.from(document.querySelectorAll('.suggestion-list .v-list-item')).find(el => el.textContent.includes('Oatmilk Cooperative')).click()")
  await expectLabel(page.locator('.comment-form'), 'Oatmilk Cooperative')
  await screenshot.captureRegion(
    'discussions/notifying_people/mentioning_group_2',
    ['.comment-form'],
    {width: 1000, height: 1200, padding: 16}
  );
});

test('reaction', async ({ page, manual: screenshot }) => {
  await page.setViewportSize({ width: 1100, height: 1400 })
  await page.goto('/dev/setup_manual_oatmilk_discussion_intro')
  await expect(page.locator('.topic-page').first()).toBeVisible()
  await expectLabel(page.locator('.topic-page'), 'Improve the cafe bottle return process')
  await page.locator('.topic-new-discussion .emoji-picker__toggle').click()
  await expect(page.locator('.emoji-picker').first()).toBeVisible()
  await page.evaluate(`
    document.querySelector('.v-app-bar')?.remove();
    document.querySelector('.topic-sidebar')?.style.setProperty('visibility', 'hidden');
    document.querySelector('.actions-panel')?.style.setProperty('visibility', 'hidden');
    document.querySelectorAll('.topic-item__gutter').forEach((gutter) => {
      gutter.style.visibility = 'hidden';
    });
    document.querySelectorAll('.topic-item__intersection-container').forEach((item) => {
      if (!item.querySelector('.topic-new-discussion')) item.style.visibility = 'hidden';
    });
  `)
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

test('thread_invite_icon', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await expect(page.locator('.topic-sidebar .action-dock__button--announce_thread').first()).toBeVisible()
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

test('thread_invite', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.locator('.topic-sidebar .action-dock__button--announce_thread').click()
  await expect(page.locator('.topic-members-list').first()).toBeVisible()
  await page.evaluate("document.querySelector('.topic-members-list > .v-list').style.display = 'none'")
  await screenshot.captureElement('discussions/notifying_people/thread_invite', '.topic-members-list', {
    width: 1100,
    height: 1200
  });
});

test('invite_guest', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.locator('.topic-sidebar .action-dock__button--announce_thread').click()
  await expect(page.locator('.topic-members-list').first()).toBeVisible()
  await page.locator('.topic-members-list .recipients-autocomplete input[type="text"]').pressSequentially('guest@cafecircle.example')
  await page.locator('.v-overlay--active .recipients-autocomplete-suggestion').click()
  await page.locator('.topic-members-list textarea').click()
  await page.evaluate("document.querySelector('.topic-members-list > .v-list').style.display = 'none'")
  await screenshot.captureElement('discussions/notifying_people/invite_guest', '.topic-members-list', {
    width: 1100,
    height: 1200
  });
});

test('thread_edit_context', async ({ page, manual: screenshot }) => {
  await prepareDiscussionEdit(page);
  await screenshot.captureElement('discussions/notifying_people/thread_editcontext', '.discussion-form', {
    width: 1100,
    height: 1500
  });
});

test('thread_edit_comment', async ({ page, manual: screenshot }) => {
  await prepareDiscussionEdit(page);
  await page.locator('.discussion-form .lmo-textarea [contenteditable=true]').evaluate((editor, html) => {
    editor.focus()
    editor.innerHTML = html
    editor.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText' }))
  }, richText.context('notified-thread-edit', [
    'Several cafe customers have asked whether we can supply oat milk in returnable glass bottles.',
    'Use this thread to compare collection dates, bottle deposits, washing checks, and responsibilities for the trial.',
    'We will record return rates, cleaning time, damaged bottles, and transport costs before reviewing the result.'
  ]))
  await page.locator('.discussion-form__submit').click()
  await expect(page.locator('.topic-item__discussion-edited').first()).toBeVisible()
  await expectLabel(page.locator('.topic-item__discussion-edited'), 'edited the thread context')
  await page.evaluate(`
    const target = document.querySelector('.topic-item__discussion-edited');
    document.querySelector('.v-app-bar')?.remove();
    document.querySelector('.actions-panel')?.style.setProperty('visibility', 'hidden');
    document.querySelectorAll('.topic-item__intersection-container').forEach((item) => {
      if (!item.contains(target)) item.style.visibility = 'hidden';
    });
  `)
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

test('thread_engagement', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await expect(page.locator('.topic-sidebar .action-dock__button--seen_by').first()).toBeVisible()
  await expect(page.locator('.topic-sidebar .action-dock__button--users_notified').first()).toBeVisible()
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

test('thread_seen_by', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.locator('.topic-sidebar .action-dock__button--seen_by').click()
  await expect(page.locator('.v-overlay--active .v-card').first()).toBeVisible()
  await expectLabel(page.locator('.v-overlay--active .v-card'), 'Seen by')
  await expectLabel(page.locator('.v-overlay--active .v-card'), 'Jamie Chen')
  await screenshot.captureElement('discussions/notifying_people/thread_seenby', '.v-overlay--active .v-card', {
    width: 1100,
    height: 1000
  });
});

test('thread_notified', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.locator('.topic-sidebar .action-dock__button--users_notified').click()
  await expect(page.locator('.v-overlay--active .v-card').first()).toBeVisible()
  await expectLabel(page.locator('.v-overlay--active .v-card'), 'Thread notification history')
  await screenshot.captureElement('discussions/notifying_people/thread_notified', '.v-overlay--active .v-card', {
    width: 1100,
    height: 1200
  });
});

test('thread_notification_history', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await expect(page.locator('.topic-sidebar .action-dock__button--users_notified').first()).toBeVisible()
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

test('comment_notification_history', async ({ page, manual: screenshot }) => {
  await postMentionComment(page);
  await page.evaluate("document.querySelector('.flash-root')?.remove()")
  await page.locator('.manual-mention-comment .action-menu').click()
  await expect(page.locator('.v-overlay--active .action-dock__button--notification_history').first()).toBeVisible()
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

test('comment_notification_example', async ({ page, manual: screenshot }) => {
  await postMentionComment(page);
  await page.evaluate("document.querySelector('.flash-root')?.remove()")
  await page.locator('.manual-mention-comment .action-menu').click()
  await page.evaluate("document.querySelector('.v-overlay--active .action-dock__button--notification_history').click()")
  await expect(page.locator('.v-overlay--active .v-card').first()).toBeVisible()
  await expectLabel(page.locator('.v-overlay--active .v-card'), 'Comment notification history')
  await expectLabel(page.locator('.v-overlay--active .v-card'), 'Samira Patel')
  await screenshot.captureElement('discussions/notifying_people/comment_notification_example', '.v-overlay--active .v-card', {
    width: 1100,
    height: 1000
  });
});

test('poll_notification_history', async ({ page, manual: screenshot }) => {
  await revealPoll(page);
  await page.locator('.poll-created .action-menu').click()
  await expect(page.locator('.v-overlay--active .action-dock__button--notification_history').first()).toBeVisible()
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

test('poll_notification_example', async ({ page, manual: screenshot }) => {
  await revealPoll(page);
  await page.locator('.poll-created .action-menu').click()
  await page.evaluate("document.querySelector('.v-overlay--active .action-dock__button--notification_history').click()")
  await expect(page.locator('.v-overlay--active .v-card').first()).toBeVisible()
  await expectLabel(page.locator('.v-overlay--active .v-card'), 'Poll notification history')
  await expectLabel(page.locator('.v-overlay--active .v-card'), 'Samira Patel')
  await screenshot.captureElement('discussions/notifying_people/poll_notification_example', '.v-overlay--active .v-card', {
    width: 1100,
    height: 1000
  });
});

test('thread_interact', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.evaluate("document.querySelector('.topic-sidebar .topic-sidebar__notification-settings').classList.add('manual-volume-control')")
  await expect(page.locator('.topic-sidebar .manual-volume-control').first()).toBeVisible()
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
