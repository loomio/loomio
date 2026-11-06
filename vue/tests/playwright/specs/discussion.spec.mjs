import { test, expect } from '../fixtures.mjs';
import { blockMainContentRequests } from '../helpers/initialPage.mjs';
import { signUpViaInvitation, signInViaPassword } from '../helpers/accounts.mjs';
import { editor } from '../helpers/editor.mjs';
import { pollAction } from '../helpers/polls.mjs';
import { addRecipient } from '../helpers/recipients.mjs';
import { comment, commentForm, itemAction, mention, postComment, replyForm, thread } from '../helpers/threads.mjs';
import { choose, search } from '../helpers/vuetify.mjs';
import { ensureSidebar } from '../helpers/groups.mjs';

const heading = page => page.locator('.context-panel__heading');
const description = page => page.locator('.context-panel__description');
const mentionCount = page => page.locator('.mention-notifications-count');

test.describe('viewing threads', () => {
  test('a thread boots with its records when the startup API requests are unavailable', async ({ page }) => {
    const requests = await blockMainContentRequests(page);
    await page.goto('/dev/setup_discussion');
    await expect(heading(page)).toContainText('What star sign are you?');
    await expect(page.locator('.comment-form')).toBeVisible();
    expect(requests).toEqual([]);
    await page.reload();
    await expect(heading(page)).toContainText('What star sign are you?');
    expect(requests).toEqual([]);
  });

  test('a visitor reads a public thread', async ({ page }) => {
    await page.goto('/dev/view_open_group_as_visitor');
    await expect(page.locator('.group-page__name')).toContainText('Open Dirty Dancing Shoes');
    await expect(page.locator('.navbar__sign-in')).toBeVisible();
    await page.locator('.topic-preview__link', { hasText: 'I carried a watermelon' }).click();
    await expect(heading(page)).toContainText('I carried a watermelon');
    const requests = await blockMainContentRequests(page);
    await page.reload();
    await expect(heading(page)).toContainText('I carried a watermelon');
    expect(requests).toEqual([]);
  });

  test('content shows timestamps', async ({ page }) => {
    await page.goto('/dev/view_open_group_as_non_member');
    await page.locator('.topic-preview__link').click();
    await expect(page.locator('.time-ago').first()).toBeVisible();
  });
});

test.describe('managing a thread', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/dev/setup_discussion');
  });

  test('edits the title and context', async ({ page }) => {
    await page.locator('.context-panel .action-dock__button--edit_thread').click();
    await page.locator('.discussion-form__title-input input').fill('better title');
    await page.locator('.discussion-form .lmo-textarea textarea').fill('improved description');
    await page.locator('.discussion-form__submit').click();
    await expect(heading(page)).toContainText('better title');
    await expect(description(page)).toContainText('improved description');
  });

  test('moves a group thread to a direct thread', async ({ page }) => {
    await page.locator('.topic-sidebar .action-dock__button--move_thread').click();
    await choose(page, '.move-topic-form__group-dropdown', 'Direct thread');
    await expect(page.locator('.move-topic-form')).toContainText('Everyone who has participated will retain access');
    await page.locator('.move-topic-form__submit').click();
    await expect(page.locator('.context-panel__breadcrumbs')).toContainText('Direct');
  });

  test('a group admin deletes the thread', async ({ page, flash }) => {
    await page.locator('.topic-sidebar .action-dock__button--discard_thread').click();
    await page.locator('.confirm-modal__submit').click();
    await expect(flash).toContainText('Discussion deleted');
    await expect(page.locator('.group-page__name')).toContainText('Dirty Dancing Shoes');
    await expect(page.locator('.topic-preview', { hasText: 'What star sign are you?' })).toHaveCount(0);
  });

  test('reacts to the thread', async ({ page }) => {
    await expect(page.locator('.reactions-display')).toHaveCount(0);
    await page.locator('.context-panel .emoji-picker__toggle').click();
    // Hearts show in the quick picks and the full list; either will do.
    await page.locator('.v-overlay--active .emoji-picker__emoji[data-shortcode="red_heart"]').first().click();
    await expect(page.locator('.context-panel .reactions-display')).toBeVisible();
  });

  test('starts a direct thread and comments in it', async ({ page, flash }) => {
    await ensureSidebar(page);
    await page.locator('.sidebar__list-item-button--private').click();
    await page.locator('.topics-page__new-topic-button').click();
    await page.locator('.discussion-templates--direct-discussion').click();
    await addRecipient(page, 'test@example.com');
    await page.locator('.discussion-form__title-input input').fill('private thread');
    await page.locator('.discussion-form__submit').click();
    await expect(flash).toContainText('Discussion started');
    await postComment(page, 'Hello world!');
    await expect(flash).toContainText('Comment added');
  });
});

test('locks a thread and unlocks it again', async ({ page, flash }) => {
  await page.goto('/dev/setup_open_and_closed_discussions');
  const previews = page.locator('.topic-preview');
  await expect(previews).toContainText(['What star sign are you?']);
  await page.locator('.discussions-panel__filters').click();
  await page.locator('.discussions-panel__filters-locked').click();
  await expect(previews).toContainText(['This thread is old and closed']);
  await page.locator('.discussions-panel__filters').click();
  await page.locator('.discussions-panel__filters-all').click();
  await previews.filter({ hasText: 'What star sign are you?' }).click();

  await page.locator('.topic-sidebar .action-dock__button--lock_thread').click();
  await expect(flash).toContainText('Thread locked');
  await page.locator('.topic-sidebar .action-dock__button--unlock_thread').click();
  await expect(flash).toContainText('Thread unlocked');
});

test('saving notification settings updates the sidebar', async ({ page, flash }) => {
  await page.goto('/dev/setup_manual_oatmilk_discussion');
  const settings = page.locator('.topic-sidebar__notification-settings');
  const changeVolume = async volume => {
    await settings.click();
    await page.locator(`.volume-${volume} label`).click();
    await page.locator('.change-volume-form__submit').click();
    await expect(flash).toContainText('Notification settings updated');
    await expect(page.locator('.change-volume-form')).toHaveCount(0);
    await expect(page.locator('.topic-sidebar__notification-email-icon')).toBeVisible();
    await expect(page.locator('.topic-sidebar__notification-device-icon')).toHaveCount(0);
  };

  await changeVolume('loud');
  await expect(settings).toContainText('Email all activity');
  await changeVolume('quiet');
  await expect(settings).toContainText('Daily catch-up email');
});

test.describe('commenting', () => {
  test('a non-member joins an open group and comments', async ({ page, flash }) => {
    await page.goto('/dev/view_open_group_as_non_member');
    await page.locator('.topic-preview__link').click();
    await page.locator('.join-group-button').click();
    await expect(flash).toContainText('You are now a member of Open Dirty Dancing Shoes');
    await postComment(page, 'I am new!');
    await expect(flash).toContainText('Comment added');
  });

  test('a guest comments and finds the thread under recent threads', async ({ page, flash }) => {
    await page.goto('/dev/setup_discussion_as_guest');
    await postComment(page, 'I am a guest!');
    await expect(flash).toContainText('Comment added');
    await ensureSidebar(page);
    await page.locator('.sidebar__list-item-button--recent').click();
    await expect(page.locator('.topic-preview')).toContainText('Dirty Dancing Shoes');
  });

  test.describe('in a thread', () => {
    test.beforeEach(async ({ page }) => {
      await page.goto('/dev/setup_discussion');
    });

    test('adds a comment', async ({ page }) => {
      await postComment(page, 'hi this is my comment');
      await expect(comment(page, 'hi this is my comment')).toBeVisible();
    });

    test('replies to a comment', async ({ page }) => {
      await postComment(page, 'original comment');
      await comment(page, 'original comment').locator('.action-dock__button--reply_to_comment').click();
      await postComment(page, 'a reply', replyForm(page));
      await expect(comment(page, 'a reply')).toBeVisible();
      await expect(replyForm(page)).toHaveCount(0);
    });

    test('edits a comment and mentions someone', async ({ page }) => {
      await postComment(page, 'original comment');
      await comment(page, 'original comment').locator('.action-dock__button--edit_comment').click();
      const edit = editor(page.locator('.edit-comment-form'));
      await edit.press('ControlOrMeta+a');
      await edit.pressSequentially('edited comment ');
      await mention(page, edit, '@patrick', 'patrickswayze');
      await page.locator('.edit-comment-form .comment-form__submit-button').click();
      await expect(page.locator('.new-comment')).toContainText('edited comment @Patrick Swayze');
    });

    test('discards a comment, restores it, then deletes it', async ({ page }) => {
      const removed = page.locator('.topic-item__removed');
      await postComment(page, 'original comment');
      await itemAction(page, comment(page, 'original comment'), 'discard_comment');
      await expect(removed).toContainText('Item removed');
      await expect(comment(page, 'original comment')).toHaveCount(0);

      await itemAction(page, removed, 'undiscard_comment');
      await expect(comment(page, 'original comment')).toBeVisible();

      await itemAction(page, comment(page, 'original comment'), 'discard_comment');
      await itemAction(page, removed, 'delete_comment');
      await page.locator('.confirm-modal__submit').click();
      await expect(removed).toHaveCount(0);
      await expect(comment(page, 'original comment')).toHaveCount(0);
    });
  });
});

test.describe('mentions', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/dev/setup_discussion');
  });

  test('mentioning a group notifies its members', async ({ page }) => {
    await expect(mentionCount(page)).toContainText('Type @ to notify people');
    await mention(page, editor(commentForm(page)), 'Hello @', 'shoes');
    await expect(mentionCount(page)).toContainText('2 people will be notified');
  });

  test('mentioning a person notifies them', async ({ page }) => {
    await mention(page, editor(commentForm(page)), '@patrick', 'patrickswayze');
    await expect(mentionCount(page)).toContainText('1 person will be notified');
  });

  test('a posted mention shows the person\'s name', async ({ page }) => {
    await mention(page, editor(commentForm(page)), '@jennifer', 'jennifergrey');
    await commentForm(page).locator('.comment-form__submit-button').click();
    await expect(page.locator('.new-comment')).toContainText('@Jennifer Grey');
  });

  test('a copied and pasted mention stays one mention', async ({ page }) => {
    await mention(page, editor(commentForm(page)), '@jennifer', 'jennifergrey');
    await commentForm(page).locator('.comment-form__submit-button').click();
    // Wait for the form to clear after posting, or the reset wipes the paste.
    await expect(mentionCount(page)).toContainText('Type @ to notify people');

    await page.locator('.new-comment [data-mention-id="jennifergrey"]').selectText();
    await page.keyboard.press('ControlOrMeta+c');
    const input = editor(commentForm(page));
    await input.click();
    await page.keyboard.press('ControlOrMeta+v');
    await expect(mentionCount(page)).toContainText('1 person will be notified');
    await expect(input.locator('[data-mention-id="jennifergrey"]')).toHaveCount(1);
  });

  test('mentions in the Markdown editor', async ({ page }) => {
    const input = commentForm(page).locator('.lmo-textarea textarea');
    await page.locator('.html-editor__expand').click();
    await page.locator('.e2e-markdown-btn').click();
    await mention(page, input, 'Hello @', 'shoes');
    await expect(mentionCount(page)).toContainText('2 people will be notified');
    await mention(page, input, ' @jennifer', 'jennifergrey');
    await commentForm(page).locator('.comment-form__submit-button').click();
    await expect(page.locator('.new-comment')).toContainText('@jennifergrey');
  });
});

test('mention suggestions rank prefix matches first', async ({ page }) => {
  await page.goto('/dev/setup_discussion_for_mention_ranking');
  await editor(commentForm(page)).pressSequentially('@sco');
  await expect(page.locator('.suggestion-list .v-list-item')).toContainText(['Scott Lemmon', 'Jerry Scott']);
});

test.describe('revision history', () => {
  const history = page => page.locator('.revision-history-content');

  test('of a comment', async ({ page }) => {
    await page.goto('/dev/setup_comment_with_versions');
    await page.locator('.action-dock__button--show_history').click();
    await expect(history(page).locator('del')).toContainText('star');
    await expect(history(page).locator('ins')).toContainText('moon');
  });

  test('of a thread', async ({ page }) => {
    await page.goto('/dev/setup_discussion_with_versions');
    await page.locator('.topic-new-discussion .action-dock__button--show_history').click();
    await expect(history(page).locator('del')).toContainText('star');
    await expect(history(page).locator('ins')).toContainText('moon');
  });

  test('escapes markup in a thread title', async ({ page }) => {
    await page.goto('/dev/setup_discussion_with_unsafe_title_version');
    await page.locator('.topic-new-discussion .action-dock__button--show_history').click();
    await expect(history(page).locator('ins')).toContainText('<img src=x onerror=alert(document.domain)>');
    await expect(history(page).locator('img')).toHaveCount(0);
  });
});

test.describe('arriving from an email', () => {
  test('a member opens the announced thread and comments', async ({ page }) => {
    await page.goto('/dev/setup_discussion_mailer_discussion_announced_email');
    await expect(page.locator('.email-notification-text')).toContainText('invited you to a discussion');
    await expect(page.locator('body')).toContainText('A description for this discussion. Should this be rich?');
    await page.locator('.notification-title__link--discussion').click();
    await expect(heading(page)).toContainText('go to the moon');
    await expect(description(page)).toContainText('A description for this discussion');
    await expect(page.locator('.context-panel__breadcrumbs')).toContainText('Girdy Dancing Shoes');
    await postComment(page, 'Hello world!');
    await expect(comment(page, 'Hello world!').locator('.topic-item__title')).toContainText('Jennifer Grey');
  });

  test('a signed-out member signs in to the thread', async ({ page, flash }) => {
    await page.goto('/dev/setup_discussion_mailer_member_invitation_signed_out');
    await page.locator('.notification-title__link--discussion').click();
    await signInViaPassword(page, 'discussion-member@example.com', 'password');
    await expect(flash).toContainText('Signed in successfully');
    await expect(heading(page)).toContainText('Member invitation discussion');
  });

  test('an invited person signs up and sees the thread', async ({ page, flash }) => {
    await page.goto('/dev/setup_discussion_mailer_invitation_created_email');
    const email = page.locator('body');
    await expect(page.locator('.email-notification-text')).toContainText('invited you to a discussion');
    await expect(email).toContainText('A description for this discussion. Should this be rich?');
    await expect(email).toContainText('Poll details for the invitation email.');
    await expect(email).toContainText('Please vote');
    await page.locator('.notification-title__link--discussion').click();
    await expect(page.locator('.auth-email-form__email input')).toHaveValue('jen@example.com');
    await signUpViaInvitation(page, 'Jennifer');
    await expect(flash).toContainText('Signed in successfully');
    await expect(heading(page)).toContainText('go to the moon');
    await expect(description(page)).toContainText('A description for this discussion');
    await expect(comment(page, 'body of the comment')).toBeVisible();
  });
});

test.describe('moving items between threads', () => {
  test('moves a comment to another thread', async ({ page }) => {
    await page.goto('/dev/setup_forkable_discussion');
    await itemAction(page, comment(page, 'totally on topic'), 'move_event');
    await page.locator('.discussion-fork-actions__move').click();
    await search(page, '.move-comments-modal__thread', 'Waking', 'Waking Up in Reno');
    await page.locator('.move-comments-modal__submit').click();
    await expect(heading(page)).toContainText('Waking Up in Reno');
    await page.reload();
    await expect(comment(page, 'totally on topic')).toBeVisible();
  });

  test('adds a standalone poll to a thread', async ({ page }) => {
    await page.goto('/dev/setup_topical_poll_to_add_to_discussion');
    await expect(heading(page)).toContainText('Topical proposal to move');
    await pollAction(page, 'add_to_discussion');
    await search(page, '.add-to-discussion-modal__thread', 'Waking', 'Waking Up in Reno');
    await page.locator('.add-to-discussion-modal__submit').click();
    await expect(heading(page)).toContainText('Waking Up in Reno');
    await page.reload();
    await expect(thread(page)).toContainText('Topical proposal to move');
    await expect(thread(page)).toContainText('A comment on the topical poll');
  });
});
