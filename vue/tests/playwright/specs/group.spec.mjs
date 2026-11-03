import { test, expect } from '../fixtures.mjs';
import { signUpViaEmail } from '../helpers/accounts.mjs';
import { editor } from '../helpers/editor.mjs';
import { groupAction, openSidebar, sidebarGroup } from '../helpers/groups.mjs';
import { openThreadForm } from '../helpers/threads.mjs';

const groupName = page => page.locator('.group-page__name');
const forbidden = page => page.locator('.error-page__forbidden');

test.describe('the sidebar', () => {
  test('shows the parent group of a subgroup member', async ({ page }) => {
    await page.goto('/dev/visit_group_as_subgroup_member');
    await expect(groupName(page)).toContainText('Point Break');
    await expect(page.locator('.join-group-button')).toBeVisible();
    await openSidebar(page);
    await expect(sidebarGroup(page, 'Point Break')).toBeVisible();
  });

  test('links to an accessible subgroup when its parent is private', async ({ page }) => {
    await page.goto('/dev/visit_subgroup_with_inaccessible_parent');
    await expect(groupName(page)).toContainText('Accessible Subgroup');
    await openSidebar(page);
    await expect(page.locator('.sidebar__groups')).not.toContainText('Private Parent');
    await sidebarGroup(page, 'Accessible Subgroup').click();
    await expect(groupName(page)).toContainText('Accessible Subgroup');
    await expect(forbidden(page)).toHaveCount(0);
  });

  test('keeps the routed panel mounted while changing groups', async ({ page }) => {
    const rendererErrors = [];
    const isRendererError = message => /parentNode|emitsOptions|\bbum\b|\bexposed\b/.test(message);
    page.on('console', message => {
      if (message.type() === 'error' && isRendererError(message.text())) { rendererErrors.push(message.text()); }
    });
    page.on('pageerror', error => {
      if (isRendererError(String(error))) { rendererErrors.push(String(error)); }
    });

    await page.goto('/dev/setup_group_route_transitions');
    await openSidebar(page);
    // Delay the group refresh until the new group's page has rendered.
    await page.route('**/api/v1/groups/**', async route => {
      await new Promise(resolve => setTimeout(resolve, 200));
      await route.continue();
    });
    const refreshed = page.waitForResponse('**/api/v1/groups/**');
    await sidebarGroup(page, 'Point Break').click();
    await expect(groupName(page)).toContainText('Point Break');
    const panel = await page.locator('.discussions-panel').elementHandle();
    await refreshed;
    // Let the app handle the response before checking the panel.
    await page.evaluate(() => new Promise(requestAnimationFrame));

    expect(await panel.evaluate(element => element.isConnected), 'the panel is not remounted').toBe(true);
    expect(rendererErrors).toEqual([]);
  });
});

test.describe('visiting a group', () => {
  test('a visitor signs up to join an open group', async ({ page }) => {
    await page.goto('/dev/view_open_group_as_visitor');
    await page.locator('.join-group-button').click();
    await signUpViaEmail(page, 'new@account.com');
    await page.locator('.join-group-button').click();
    await openSidebar(page);
    await expect(sidebarGroup(page, 'Open Dirty Dancing Shoes')).toBeVisible();
  });

  test('a visitor cannot dismiss or mute threads', async ({ page }) => {
    await page.goto('/dev/view_open_group_as_visitor');
    await expect(page.locator('.topic-preview').first()).toBeVisible();
    await expect(page.locator('.topic-preview__dismiss')).toHaveCount(0);
    await expect(page.locator('.topic-preview__mute')).toHaveCount(0);
  });

  test('a non-member joins an open group', async ({ page, flash }) => {
    await page.goto('/dev/view_open_group_as_non_member');
    await page.locator('.join-group-button').click();
    await expect(flash).toContainText('You are now a member');
  });

  test('a non-member asks to join a closed group', async ({ page, flash }) => {
    await page.goto('/dev/view_closed_group_as_non_member');
    await page.locator('.join-group-button').click();
    await page.locator('.membership-request-form__introduction textarea').fill('I have a reason');
    await page.locator('.membership-request-form__submit-btn').click();
    await expect(flash).toContainText('You have requested to join');
  });

  test('a non-member cannot see a secret group', async ({ page }) => {
    await page.goto('/dev/view_secret_group_as_non_member');
    await expect(forbidden(page)).toContainText('You do not have permission to view this');
    await expect(forbidden(page)).toContainText('You may be signed in to the wrong account');
  });

  test('a cached secret group becomes forbidden when access is revoked', async ({ page }) => {
    await page.goto('/dev/setup_secret_group_with_access');
    await expect(groupName(page)).toContainText('Secret Dirty Dancing Shoes');
    await openSidebar(page);
    await expect(sidebarGroup(page, 'Secret Dirty Dancing Shoes')).toBeVisible();

    expect((await page.request.get('/dev/revoke_secret_group_access')).ok()).toBe(true);

    await page.locator('.sidebar__list-item-button--recent').click();
    await expect(page.locator('.dashboard-page')).toBeVisible();
    await openSidebar(page);
    await sidebarGroup(page, 'Secret Dirty Dancing Shoes').click();
    await expect(forbidden(page)).toContainText('You do not have permission to view this');
    await expect(groupName(page)).toHaveCount(0);
  });

  test('shows threads from subgroups', async ({ page }) => {
    await page.goto('/dev/setup_group_with_subgroups');
    await expect(page.locator('.discussions-panel__list')).toContainText('Vaya con dios');
  });

  test('parent members see private threads in a closed subgroup', async ({ page }) => {
    await page.goto('/dev/setup_subgroup_with_parent_member_visibility');
    await expect(page.locator('.discussions-panel__list')).toContainText('Vaya con dios');
  });
});

test('filters group polls by status, type and tag', async ({ page }) => {
  await page.goto('/dev/setup_group_poll_filters');
  await page.locator('.group-page-polls-tab').click();
  const polls = page.locator('.polls-panel');
  const important = 'Open important proposal needing a vote';
  const voted = 'Open other poll already voted on';
  const closed = 'Closed untagged poll';
  const expectPolls = async shown => {
    for (const title of [important, voted, closed]) {
      if (shown.includes(title)) { await expect(polls).toContainText(title); }
      else { await expect(polls).not.toContainText(title); }
    }
  };
  const filter = async (menu, option) => {
    await page.locator(menu).click();
    await page.locator(`.v-overlay--active ${option}`).click();
    // A click on the next menu is lost while this one is still closing.
    await expect(page.locator('.v-overlay--active')).toHaveCount(0);
  };

  await expectPolls([important, voted, closed]);
  await filter('.polls-panel__status-filter', '.polls-panel__status-active');
  await expectPolls([important, voted]);
  await filter('.polls-panel__status-filter', '.polls-panel__status-vote');
  await expectPolls([important]);
  await filter('.polls-panel__status-filter', '.polls-panel__status-closed');
  await expectPolls([closed]);
  await filter('.polls-panel__status-filter', '.polls-panel__status-any');
  await expectPolls([important, voted, closed]);

  await filter('.polls-panel__type-filter', '.polls-panel__type-option[data-poll-type="proposal"]');
  await expectPolls([important]);
  await filter('.polls-panel__type-filter', '.polls-panel__type-any');
  await expectPolls([important, voted, closed]);

  await filter('.tags-filter-menu__button', '.tags-filter-menu__tag[data-tag-name="Important"]');
  await expectPolls([important]);
  await filter('.tags-filter-menu__button', '.tags-filter-menu__all-tags');
  await expectPolls([important, voted, closed]);
});

test.describe('starting groups', () => {
  test('starts a group', async ({ page, flash }) => {
    await page.goto('/dev/setup_dashboard');
    await openSidebar(page);
    await page.locator('.sidebar-start-group').click();
    await page.locator('.group-form__name input').fill('Secret please');
    await page.locator('.group-form__category-select .v-field').click();
    // Any category will do.
    await page.locator('.v-overlay--active .v-list-item').first().click();
    await page.locator('.group-form__submit-button').click();
    await expect(flash).toContainText('Group started');
  });

  for (const { privacy, joining, grantedOnRequest, parentMembersCanSee } of [
    { privacy: 'open', joining: true, parentMembersCanSee: false },
    { privacy: 'closed', joining: true, grantedOnRequest: true, parentMembersCanSee: true },
    { privacy: 'secret', joining: false, parentMembersCanSee: false },
  ]) {
    test(`starts a ${privacy} subgroup`, async ({ page, flash }) => {
      const shown = visible => visible ? 1 : 0;
      await page.goto('/dev/setup_open_group');
      await openSidebar(page);
      await page.locator('.sidebar-start-subgroup').click();
      await page.locator('.group-form__name input').fill(`${privacy} please`);
      await page.locator(`.group-form__privacy-${privacy}`).click();
      await expect(page.locator('.group-form__joining')).toHaveCount(shown(joining));
      if (grantedOnRequest) { await expect(page.locator('.group-form__membership-granted-upon-request')).toBeVisible(); }
      await page.locator('.group-form__submit-button').click();
      await expect(flash).toContainText('Group started');

      await groupAction(page, 'edit_group');
      await page.locator('.group-form__permissions-tab').click();
      await expect(page.locator('.group-form__parent-members-can-see-discussions')).toHaveCount(shown(parentMembersCanSee));
    });
  }
});

test.describe('managing a group', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/dev/setup_group');
  });

  test('edits the name and description', async ({ page }) => {
    await groupAction(page, 'edit_group');
    await page.locator('.group-form__name input').fill('Clean Dancing Shoes');
    await page.locator('.group-form__group-description .lmo-textarea textarea').fill('Dusty sandles');
    await page.locator('.group-form__submit-button').click();
    await expect(groupName(page)).toContainText('Clean Dancing Shoes');
  });

  test('starts a thread with a tag', async ({ page, flash }) => {
    await openThreadForm(page);
    const form = page.locator('.discussion-form');
    await form.locator('.discussion-form__title-input input').fill('Nobody puts baby in a corner');
    await editor(form).fill("I've had the time of my life");
    await form.locator('.tags-field__input input').fill('#important');
    await form.locator('.discussion-form__submit').click();
    await expect(flash).toContainText('Discussion started');
    await expect(page.locator('.context-panel__heading')).toContainText('Nobody puts baby in a corner');
    await expect(page.locator('.context-panel__description')).toContainText("I've had the time of my life");
    await expect(page.locator('.tags-display')).toContainText('#important');
  });

  test('changes notification settings', async ({ page, flash }) => {
    await groupAction(page, 'change_volume');
    await page.locator('.volume-loud label').click();
    await page.locator('.change-volume-form__submit').click();
    await expect(flash).toContainText('Notification settings updated');
  });

  test.describe('tags', () => {
    const tags = page => page.locator('.tags-modal');
    const tag = (page, name) => tags(page).locator('.v-list-item', { hasText: name });
    const saveTag = async (page, name) => {
      await page.locator('.tags-modal__tag-name input').fill(name);
      await page.locator('.tag-form__submit').click();
    };

    test.beforeEach(async ({ page }) => {
      await groupAction(page, 'edit_tags');
    });

    test('creates and deletes a tag', async ({ page, flash }) => {
      await page.locator('.tag-form__new-tag').click();
      await saveTag(page, '#important');
      await tag(page, '#important').locator('.tag-form__delete').click();
      await expect(page.locator('.confirm-modal')).toContainText('Delete tag');
      await page.locator('.confirm-modal__submit').click();
      await expect(flash).toContainText('Tag deleted');
      await expect(tags(page)).not.toContainText('#important');
    });

    for (const [before, after] of [['#important', '#renamed'], ['advice', 'Advice']]) {
      test(`renames ${before} to ${after}`, async ({ page }) => {
        await page.locator('.tag-form__new-tag').click();
        await saveTag(page, before);
        await tag(page, before).locator('.tag-form__edit-tag').click();
        await saveTag(page, after);
        await expect(tags(page).locator('.v-list-item-title')).toHaveText([after]);
      });
    }
  });
});

test('a member leaves a group', async ({ page, flash }) => {
  await page.goto('/dev/setup_group_with_multiple_coordinators');
  await groupAction(page, 'leave_group');
  await page.locator('.confirm-modal__submit').click();
  await expect(flash).toContainText('You have left this group');
  await expect(page.locator('.dashboard-page__empty')).toContainText('Welcome! You are not a member of any groups yet.');
});

test.describe('as a site admin', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/dev/setup_group_super_admin');
  });

  test('deletes a group', async ({ page, flash }) => {
    await groupAction(page, 'destroy_group');
    await page.locator('.confirm-text-field input').fill('shoes');
    await page.locator('.confirm-modal__submit').click();
    await expect(flash).toContainText('This group is unavailable and will be permanently deleted after 90 days');
  });

  test('exports a group as HTML', async ({ page, flash }) => {
    await groupAction(page, 'export_data');
    await page.locator('.export-data-modal__html').click();
    await expect(page.locator('.confirm-modal')).toContainText("When it's ready you'll receive an email");
    await page.locator('.confirm-modal__submit').click();
    await expect(flash).toContainText('Group data export started');
  });
});

test('removes the group logo and cover photo', async ({ page, flash }) => {
  await page.goto('/dev/setup_group_with_photos');
  await groupAction(page, 'edit_group');
  for (const [image, message] of [['logo', 'Logo removed'], ['cover-photo', 'Cover photo removed']]) {
    const remove = page.locator(`.group-form__remove-${image}`);
    await remove.click();
    await expect(flash).toContainText(message);
    await expect(remove).toHaveCount(0);
  }
});
