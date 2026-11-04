import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

import richText from '../helpers/oatmilkRichText.mjs';
import { editor } from '../helpers/editor.mjs';
import { comment, commentForm } from '../helpers/threads.mjs';

// Clicks without moving the mouse, so no hover state shows in the capture.
const press = locator => locator.dispatchEvent('click');
const hide = locator => locator.evaluate(element => { element.style.visibility = 'hidden'; });

async function openNewDiscussionForm(page) {
  await page.goto('/dev/setup_manual_oatmilk_new_discussion')
  await page.locator('.discussions-panel__new-topic-button').click()
  await page.locator('.discussion-templates--template-blank').click()
  await expect(page.locator('.discussion-form .recipients-autocomplete')).toBeVisible()
}

async function removeDefaultAudience(page) {
  await press(page.locator('.recipients-autocomplete .v-chip__close'))
  await page.locator('.recipients-autocomplete .announcement-form__input').evaluate(input => input.scrollIntoView({block: 'center'}))
}

async function openDiscussion(page) {
  await page.goto('/dev/setup_manual_oatmilk_discussion')
  await expectLabel(page.locator('.topic-page'), 'Returnable bottles for cafe customers')
  await expect(editor(commentForm(page))).toBeVisible()
}

async function openMentionDiscussion(page) {
  await page.setViewportSize({ width: 1000, height: 1200 })
  await page.goto('/dev/setup_manual_oatmilk_discussion_intro')
  await expectLabel(page.locator('.topic-page'), 'Improve the cafe bottle return process')
  await expect(editor(commentForm(page))).toBeVisible()
}

async function prepareDiscussionEdit(page) {
  await openDiscussion(page);
  await page.locator('.context-panel .action-dock__button--edit_thread').click()
  const message = page.locator('.discussion-form .common-notify-fields__change-log input')
  await message.fill('Added cafe collection details and clarified the proposed trial.')
  await page.locator('.discussion-form .recipients-autocomplete input[type="text"]').click()
  await page.locator('.v-overlay--active .recipients-autocomplete-suggestion--group').click()
  await message.click()
}

async function postMentionComment(page) {
  await openDiscussion(page);
  await editor(commentForm(page)).pressSequentially('Could you confirm the cafe collection dates, @samira')
  await page.locator('.suggestion-list [data-mention-handle="samirapatel"] .v-list-item-title').click()
  await commentForm(page).locator('.comment-form__submit-button').click()
  await expectLabel(page.locator('.topic-page'), 'Could you confirm the cafe collection dates')
  // Captures take CSS selectors, which cannot match text, so mark the comment.
  await comment(page, 'Could you confirm the cafe collection dates').evaluate(element => element.classList.add('manual-mention-comment'))
}

async function revealPoll(page) {
  await openDiscussion(page);
  // Older items, including the poll, may be behind a load more button.
  const loadMore = page.locator('.topic-item__load-more button')
  if (await loadMore.count()) { await press(loadMore.first()) }
  await expect(page.locator('.poll-created')).toBeVisible()
}

test('notification_recipients', async ({ page, manual: screenshot }) => {
  await openNewDiscussionForm(page);
  await press(page.locator('.recipients-autocomplete .chip--select-multi'))
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
  await expectLabel(page.locator('.v-overlay--active .recipients-autocomplete-suggestion'), 'Samira Patel')
  await hide(page.locator('.discussion-form__submit'))
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
  await expectLabel(page.locator('.v-overlay--active .recipients-autocomplete-suggestion'), 'guest@cafecircle.example')
  await hide(page.locator('.discussion-form__submit'))
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
  await editor(commentForm(page)).pressSequentially('Could you confirm the collection schedule, @samira')
  await page.locator('.suggestion-list [data-mention-handle="samirapatel"] .v-list-item-title').click()
  await screenshot.captureRegion(
    'discussions/notifying_people/comment_mention',
    ['.comment-form'],
    {width: 1000, height: 1200, padding: 16}
  );
});

test('mention_group_search', async ({ page, manual: screenshot }) => {
  await openMentionDiscussion(page);
  await editor(commentForm(page)).pressSequentially('Packaging update for @Oat')
  await expect(page.locator('.suggestion-list .v-list-item', { hasText: 'Oatmilk Cooperative' })).toBeAttached()
  await screenshot.captureRegion('discussions/notifying_people/mentioning_group_1', [
    '.comment-form',
    '.suggestion-list'
  ], {padding: 16, width: 1000, height: 1200});
});

test('mention_group_selected', async ({ page, manual: screenshot }) => {
  await openMentionDiscussion(page);
  await editor(commentForm(page)).pressSequentially('Packaging update for @Oat')
  await press(page.locator('.suggestion-list .v-list-item', { hasText: 'Oatmilk Cooperative' }))
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
  await expectLabel(page.locator('.topic-page'), 'Improve the cafe bottle return process')
  await page.locator('.topic-new-discussion .emoji-picker__toggle').click()
  await expect(page.locator('.v-overlay--active .emoji-picker')).toBeVisible()
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
  await expect(page.locator('.topic-sidebar .action-dock__button--announce_thread')).toBeVisible()
  await screenshot.capture('discussions/notifying_people/thread_invite_icon', {
    spotlight: {
      selector: '.topic-sidebar .action-dock__button--announce_thread',
      padding: 12,
      radius: 14
    },
    scrollSelector: '.topic-sidebar .action-dock__button--announce_thread',
    width: 1280,
    height: 857
  });
});

test('thread_invite', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.locator('.topic-sidebar .action-dock__button--announce_thread').click()
  await page.locator('.topic-members-list > .v-list').evaluate(list => { list.style.display = 'none'; })
  await screenshot.captureElement('discussions/notifying_people/thread_invite', '.topic-members-list', {
    width: 1100,
    height: 1200
  });
});

test('invite_guest', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.locator('.topic-sidebar .action-dock__button--announce_thread').click()
  const members = page.locator('.topic-members-list')
  await members.locator('.recipients-autocomplete input[type="text"]').pressSequentially('guest@cafecircle.example')
  await page.locator('.v-overlay--active .recipients-autocomplete-suggestion').click()
  await members.locator('textarea').click()
  // Adding a guest usually hides the member list; hide it if it is still there.
  await members.locator(':scope > .v-list').evaluateAll(lists => lists.forEach(list => { list.style.display = 'none'; }))
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
  await editor(page.locator('.discussion-form')).evaluate((element, html) => {
    element.focus()
    element.innerHTML = html
    element.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText' }))
  }, richText.context('notified-thread-edit', [
    'Several cafe customers have asked whether we can supply oat milk in returnable glass bottles.',
    'Use this thread to compare collection dates, bottle deposits, washing checks, and responsibilities for the trial.',
    'We will record return rates, cleaning time, damaged bottles, and transport costs before reviewing the result.'
  ]))
  await page.locator('.discussion-form__submit').click()
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
  await expect(page.locator('.topic-sidebar .action-dock__button--seen_by')).toBeVisible()
  await expect(page.locator('.topic-sidebar .action-dock__button--users_notified')).toBeVisible()
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
    height: 857
  });
});

test('thread_seen_by', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.locator('.topic-sidebar .action-dock__button--seen_by').click()
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
  await expectLabel(page.locator('.v-overlay--active .v-card'), 'Thread notification history')
  await screenshot.captureElement('discussions/notifying_people/thread_notified', '.v-overlay--active .v-card', {
    width: 1100,
    height: 1200
  });
});

test('thread_notification_history', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await expect(page.locator('.topic-sidebar .action-dock__button--users_notified')).toBeVisible()
  await screenshot.capture('discussions/notifying_people/thread_notification_history', {
    spotlight: {
      selector: '.topic-sidebar .action-dock__button--users_notified',
      padding: 12,
      radius: 14
    },
    width: 1280,
    height: 857
  });
});

test('comment_notification_history', async ({ page, manual: screenshot }) => {
  await postMentionComment(page);
  await page.locator('.flash-root').evaluateAll(flashes => flashes.forEach(flash => flash.remove()))
  await page.locator('.manual-mention-comment .action-menu').click()
  await expect(page.locator('.v-overlay--active .action-dock__button--notification_history')).toBeVisible()
  await screenshot.capture('discussions/notifying_people/comment_notification_history', {
    spotlight: {
      selector: '.v-overlay--active .action-dock__button--notification_history',
      padding: 12,
      radius: 14
    },
    scrollSelector: '.manual-mention-comment',
    width: 1200,
    height: 857
  });
});

test('comment_notification_example', async ({ page, manual: screenshot }) => {
  await postMentionComment(page);
  await page.locator('.flash-root').evaluateAll(flashes => flashes.forEach(flash => flash.remove()))
  await page.locator('.manual-mention-comment .action-menu').click()
  await press(page.locator('.v-overlay--active .action-dock__button--notification_history'))
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
  await expect(page.locator('.v-overlay--active .action-dock__button--notification_history')).toBeVisible()
  await screenshot.capture('discussions/notifying_people/poll_notification_history', {
    spotlight: {
      selector: '.v-overlay--active .action-dock__button--notification_history',
      padding: 12,
      radius: 14
    },
    scrollSelector: '.poll-created',
    width: 1200,
    height: 957
  });
});

test('poll_notification_example', async ({ page, manual: screenshot }) => {
  await revealPoll(page);
  await page.locator('.poll-created .action-menu').click()
  await press(page.locator('.v-overlay--active .action-dock__button--notification_history'))
  await expectLabel(page.locator('.v-overlay--active .v-card'), 'Poll notification history')
  await expectLabel(page.locator('.v-overlay--active .v-card'), 'Samira Patel')
  await screenshot.captureElement('discussions/notifying_people/poll_notification_example', '.v-overlay--active .v-card', {
    width: 1100,
    height: 1000
  });
});

test('thread_interact', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await expect(page.locator('.topic-sidebar .topic-sidebar__notification-settings')).toBeVisible()
  await screenshot.capture('discussions/notifying_people/thread_interact', {
    spotlight: {
      selector: '.topic-sidebar .topic-sidebar__notification-settings',
      padding: 12,
      radius: 14
    },
    width: 1280,
    height: 857
  });
});
