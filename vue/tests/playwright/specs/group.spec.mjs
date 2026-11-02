import { test, expect } from '../fixtures.mjs';
import { signUpViaEmail } from '../helpers/accounts.mjs';

test('displays_parent_group_in_sidebar_if_member_of_a_subgroup', async ({ page }) => {
  await page.goto('/dev/visit_group_as_subgroup_member')
  await expect(page.locator('.group-page__name')).toContainText('Point Break')
  await expect(page.locator('.join-group-button')).toBeVisible()
  await page.click('.navbar__sidenav-toggle')
  await expect(page.locator('.sidebar__groups')).toContainText('Point Break')
});

test('links to an accessible subgroup when its parent is private', async ({ page }) => {
  await page.goto('/dev/visit_subgroup_with_inaccessible_parent')
  await expect(page.locator('.group-page__name')).toContainText('Accessible Subgroup')
  await page.click('.navbar__sidenav-toggle')
  await expect(page.locator('.sidebar__groups')).toContainText('Accessible Subgroup')
  await expect(page.locator('.sidebar__groups')).not.toContainText('Private Parent')
  await page.click('.sidebar__groups a')
  await expect(page.locator('.group-page__name')).toContainText('Accessible Subgroup')
  await expect(page.locator('.error-page__forbidden')).toHaveCount(0)
});

test('should_allow_you_to_join_an_open_group', async ({ page }) => {
  await page.goto('/dev/view_open_group_as_visitor')
  await page.click('.join-group-button')
  await signUpViaEmail(page, 'new@account.com')
  await page.click('.join-group-button')
  await page.click('.navbar__sidenav-toggle')
  await expect(page.locator('.sidenav-left')).toContainText('Open Dirty Dancing Shoes')
});

test('does_not_allow_mark_as_read_or_mute', async ({ page }) => {
  await page.goto('/dev/view_open_group_as_visitor')
  await expect(page.locator('.topic-preview__dismiss')).toHaveCount(0)
  await expect(page.locator('.topic-preview__mute')).toHaveCount(0)
});

test('join_an_open_group', async ({ page }) => {
  await page.goto('/dev/view_open_group_as_non_member')
  await page.click('.join-group-button')
  await expect(page.locator('.flash-root__message')).toContainText('You are now a member')
});

test('request_to_join_a_closed_group', async ({ page }) => {
  await page.goto('/dev/view_closed_group_as_non_member')
  await page.click('.join-group-button')
  await page.fill('.membership-request-form__introduction textarea', 'I have a reason')
  await page.click('.membership-request-form__submit-btn')
  await expect(page.locator('.flash-root__message')).toContainText('You have requested to join')
});

test('secret_group', async ({ page }) => {
  await page.goto('/dev/view_secret_group_as_non_member')
  await expect(page.locator('.error-page__forbidden.v-alert')).toBeVisible()
  await expect(page.locator('.error-page__forbidden')).toContainText('You do not have permission to view this')
  await expect(page.locator('.error-page__forbidden')).toContainText('You may be signed in to the wrong account')
});

test('cached secret group becomes forbidden when access is revoked', async ({ page }) => {
  await page.goto('/dev/setup_secret_group_with_access')
  await expect(page.locator('.group-page__name')).toContainText('Secret Dirty Dancing Shoes')
  await page.click('.navbar__sidenav-toggle')
  await expect(page.locator('.sidebar__groups')).toContainText('Secret Dirty Dancing Shoes')

  const revokeStatus = await page.evaluate(async () => (await fetch('/dev/revoke_secret_group_access')).status)
  expect(revokeStatus).toBe(200)

  await page.click('.sidebar__list-item-button--recent')
  await expect(page.locator('.dashboard-page')).toBeVisible()
  await page.click('.navbar__sidenav-toggle')
  await page.click('.sidebar__groups a')
  await expect(page.locator('.error-page__forbidden.v-alert')).toBeVisible()
  await expect(page.locator('.error-page__forbidden')).toContainText('You do not have permission to view this')
  await expect(page.locator('.group-page__name')).toHaveCount(0)
});

test('keeps the routed panel mounted while changing groups', async ({ page }) => {
  await page.goto('/dev/setup_group_route_transitions')
  await page.click('.navbar__sidenav-toggle')
  await expect(page.locator('.sidebar__groups')).toContainText('Dirty Dancing Shoes')
  await expect(page.locator('.sidebar__groups')).toContainText('Point Break')

  await page.evaluate(() => {
    window.__groupRouteRendererErrors = []
    const nativeFetch = window.fetch
    window.fetch = (...args) => {
      const url = String(args[0]?.url || args[0])
      const response = nativeFetch(...args)
      if (!url.includes('/api/v1/groups/')) return response

      return new Promise((resolve, reject) => {
        setTimeout(() => response.then(resolve, reject), 200)
      })
    }
    const consoleError = console.error
    console.error = (...args) => {
      const message = args.map(String).join(' ')
      if (/parentNode|emitsOptions|\bbum\b|\bexposed\b/.test(message)) {
        window.__groupRouteRendererErrors.push(message)
      }
      consoleError(...args)
    }
    window.addEventListener('error', event => {
      const message = String(event.error || event.message)
      if (/parentNode|emitsOptions|\bbum\b|\bexposed\b/.test(message)) {
        window.__groupRouteRendererErrors.push(message)
      }
    })
  })

  await page.evaluate(() => {
    const clickGroup = name => {
      const links = Array.from(document.querySelectorAll('.sidebar__groups > .v-list-item'))
      links.find(link => link.textContent.includes(name)).click()
    }
    clickGroup('Point Break')
  })

  await expect(page.locator('.group-page__name')).toContainText('Point Break')
  await expect(page.locator('.discussions-panel')).toBeVisible()
  await page.evaluate(() => {
    document.querySelector('.discussions-panel').dataset.e2eInstance = 'original'
  })
  expect(await page.evaluate(() => document.querySelector('.discussions-panel').dataset.e2eInstance),
    'does not remount the routed panel after refreshing the group').toBe('original')
  expect(await page.evaluate(() => window.__groupRouteRendererErrors),
    'does not raise Vue renderer errors while changing groups').toEqual([])
});

test('filters_group_polls_by_status_type_and_tag', async ({ page }) => {
  await page.goto('/dev/setup_group_poll_filters')
  await page.click('.group-page-polls-tab')
  await expect(page.locator('.polls-panel')).toContainText('Open important proposal needing a vote', { timeout: 20000 })
  await expect(page.locator('.polls-panel')).toContainText('Open other poll already voted on')
  await expect(page.locator('.polls-panel')).toContainText('Closed untagged poll')

  await page.click('.polls-panel__status-filter')
  await page.click('.v-overlay--active .polls-panel__status-active')
  await expect(page.locator('.polls-panel')).toContainText('Open important proposal needing a vote')
  await expect(page.locator('.polls-panel')).toContainText('Open other poll already voted on')
  await expect(page.locator('.polls-panel')).not.toContainText('Closed untagged poll')

  await page.click('.polls-panel__status-filter')
  await page.click('.v-overlay--active .polls-panel__status-vote')
  await expect(page.locator('.polls-panel')).toContainText('Open important proposal needing a vote')
  await expect(page.locator('.polls-panel')).not.toContainText('Open other poll already voted on')
  await expect(page.locator('.polls-panel')).not.toContainText('Closed untagged poll')

  await page.click('.polls-panel__status-filter')
  await page.click('.v-overlay--active .polls-panel__status-closed')
  await expect(page.locator('.polls-panel')).toContainText('Closed untagged poll')
  await expect(page.locator('.polls-panel')).not.toContainText('Open important proposal needing a vote')
  await expect(page.locator('.polls-panel')).not.toContainText('Open other poll already voted on')

  await page.click('.polls-panel__status-filter')
  await page.click('.v-overlay--active .polls-panel__status-any')
  await expect(page.locator('.polls-panel')).toContainText('Open important proposal needing a vote')
  await expect(page.locator('.polls-panel')).toContainText('Open other poll already voted on')
  await expect(page.locator('.polls-panel')).toContainText('Closed untagged poll')

  await page.click('.polls-panel__type-filter')
  await page.click('.v-overlay--active .polls-panel__type-option[data-poll-type="proposal"]')
  await expect(page.locator('.polls-panel')).toContainText('Open important proposal needing a vote')
  await expect(page.locator('.polls-panel')).not.toContainText('Open other poll already voted on')
  await expect(page.locator('.polls-panel')).not.toContainText('Closed untagged poll')

  await page.click('.polls-panel__type-filter')
  await page.click('.v-overlay--active .polls-panel__type-any')
  await expect(page.locator('.polls-panel')).toContainText('Open other poll already voted on')
  await expect(page.locator('.polls-panel')).toContainText('Closed untagged poll')

  await page.click('.tags-filter-menu__button')
  await page.click('.v-overlay--active .tags-filter-menu__tag[data-tag-name="Important"]')
  await expect(page.locator('.polls-panel')).toContainText('Open important proposal needing a vote')
  await expect(page.locator('.polls-panel')).not.toContainText('Open other poll already voted on')
  await expect(page.locator('.polls-panel')).not.toContainText('Closed untagged poll')

  await page.click('.tags-filter-menu__button')
  await page.click('.v-overlay--active .tags-filter-menu__all-tags')
  await expect(page.locator('.polls-panel')).toContainText('Open important proposal needing a vote')
  await expect(page.locator('.polls-panel')).toContainText('Open other poll already voted on')
  await expect(page.locator('.polls-panel')).toContainText('Closed untagged poll')
});

test('displays_threads_from_subgroups_in_the_discussions_card', async ({ page }) => {
  await page.goto('/dev/setup_group_with_subgroups')
  await expect(page.locator('.discussions-panel__list')).toContainText('Vaya con dios', { timeout: 20000 })
});

test('closed_subgroup_whose_parent_members_can_see_private_threads', async ({ page }) => {
  await page.goto('/dev/setup_subgroup_with_parent_member_visibility')
  await expect(page.locator('.discussions-panel__list')).toContainText('Vaya con dios', { timeout: 20000 })
});

test('starts_a_secret_group', async ({ page }) => {
  await page.goto('/dev/setup_dashboard')
  await page.click('.navbar__sidenav-toggle')

  await page.click('.sidebar-start-group')

  await page.fill('.group-form__name input', 'Secret please')
  await page.click('.group-form__category-select .v-field')
  await page.click('.v-overlay .v-select__content .v-list-item')
  await page.click('.group-form__submit-button')
  await expect(page.locator('.flash-root__message')).toContainText('Group started')
});

test('open_subgroup', async ({ page }) => {
  await page.goto('/dev/setup_open_group')
  await page.click('.navbar__sidenav-toggle')
  await page.click('.sidebar-start-subgroup')

  await page.fill('#group-name', 'Open please')
  await page.click('.group-form__privacy-open')
  await expect(page.locator('.group-form__joining')).toBeVisible()
  await page.click('.group-form__submit-button')
  await expect(page.locator('.flash-root__message')).toContainText('Group started')

  await page.click('.action-menu')
  await page.click('.action-dock__button--edit_group')
  await page.click('.group-form__permissions-tab')

  await expect(page.locator('.group-form__parent-members-can-see-discussions')).toHaveCount(0)
});

test('closed_subgroup', async ({ page }) => {
  await page.goto('/dev/setup_open_group')
  await page.click('.navbar__sidenav-toggle')
  await page.click('.sidebar-start-subgroup')

  await page.fill('#group-name', 'Closed please')
  await page.click('.group-form__privacy-closed')
  await expect(page.locator('.group-form__joining')).toBeVisible()
  await expect(page.locator('.group-form__membership-granted-upon-request')).toBeVisible()
  await page.click('.group-form__submit-button')
  await expect(page.locator('.flash-root__message')).toContainText('Group started')

  await page.click('.action-menu')
  await page.click('.action-dock__button--edit_group')
  await page.click('.group-form__permissions-tab')

  await expect(page.locator('.group-form__parent-members-can-see-discussions')).toBeVisible()
});

test('secret_subgroup', async ({ page }) => {
  await page.goto('/dev/setup_open_group')
  await page.click('.navbar__sidenav-toggle')
  await page.click('.sidebar-start-subgroup')
  await page.fill('#group-name', 'Secret please')
  await page.click('.group-form__privacy-secret')
  await expect(page.locator('.group-form__joining')).toHaveCount(0)
  await page.click('.group-form__submit-button')
  await expect(page.locator('.flash-root__message')).toContainText('Group started')

  await page.click('.action-menu')
  await page.click('.action-dock__button--edit_group')
  await page.click('.group-form__permissions-tab')

  await expect(page.locator('.group-form__parent-members-can-see-discussions')).toHaveCount(0)
});

test('successfully_edits_group_name_and_description', async ({ page }) => {
  await page.goto('/dev/setup_group')
  await page.click('.action-menu')
  await page.click('.action-dock__button--edit_group')

  await page.fill('#group-name', 'Clean Dancing Shoes')
  await page.fill('.group-form__group-description .lmo-textarea textarea', 'Dusty sandles')
  await page.click('.group-form__submit-button')

  await expect(page.locator('.group-page__name')).toContainText('Clean Dancing Shoes')
});

test('allows_group_members_to_leave_the_group', async ({ page }) => {
  await page.goto('/dev/setup_group_with_multiple_coordinators')
  await page.click('.action-menu')
  await page.click('.action-dock__button--leave_group')
  await page.click('.confirm-modal__submit')
  await expect(page.locator('.flash-root__message')).toContainText('You have left this group')
  await expect(page.locator('.dashboard-page__empty')).toContainText('Welcome! You are not a member of any groups yet.')
});

test('starts_a_discussion', async ({ page }) => {
  await page.goto('/dev/setup_group')
  await page.click('.discussions-panel__new-topic-button')
  await page.click('.discussion-templates--template')
  await page.fill('#discussion-title', 'Nobody puts baby in a corner')
  await page.fill('.discussion-form .lmo-textarea div[contenteditable=true]', "I've had the time of my life")
  await page.fill('.discussion-form .tags-field__input input', '#important')
  await page.click('.discussion-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText("Discussion started")
  await expect(page.locator('.context-panel__heading')).toContainText('Nobody puts baby in a corner')
  await expect(page.locator('.context-panel__description')).toContainText("I've had the time of my life")
  await expect(page.locator('.tags-display')).toContainText('#important')
});

test('lets_you_change_membership_volume', async ({ page }) => {
  await page.goto('/dev/setup_group')
  await page.click('.action-menu')
  await page.click('.action-dock__button--change_volume')

  await page.click('.volume-loud label')
  await page.click('.change-volume-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Notification settings updated')
});

test('creates_and_deletes_category_tag', async ({ page }) => {
  await page.goto('/dev/setup_group')
  await page.click('.action-menu')
  await page.click('.action-dock__button--edit_tags')
  await page.click('.tag-form__new-tag')
  await page.fill('.tags-modal__tag-name input', "#important")
  await page.click('.tag-form__submit')
  await expect(page.locator('.tags-modal .v-list-item-title')).toContainText('#important')
  await page.click('.tags-modal .v-list-item .tag-form__delete')
  await expect(page.locator('.confirm-modal')).toContainText('Delete tag')
  await page.click('.confirm-modal__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Tag deleted')
  await expect(page.locator('.tags-modal')).not.toContainText('#important')
});

test('renames_category_tag', async ({ page }) => {
  await page.goto('/dev/setup_group')
  await page.click('.action-menu')
  await page.click('.action-dock__button--edit_tags')
  await page.click('.tag-form__new-tag')
  await page.fill('.tags-modal__tag-name input', "#important")
  await page.click('.tag-form__submit')
  await expect(page.locator('.tags-modal .v-list-item-title')).toContainText('#important')

  await page.click('.tags-modal .v-list-item .tag-form__edit-tag')
  await page.fill('.tags-modal__tag-name input', "#renamed")
  await page.click('.tag-form__submit')
  await expect(page.locator('.tags-modal .v-list-item-title')).toContainText('#renamed')
  await expect(page.locator('.tags-modal')).not.toContainText('#important')
});

test('renames_category_tag_case_only', async ({ page }) => {
  await page.goto('/dev/setup_group')
  await page.click('.action-menu')
  await page.click('.action-dock__button--edit_tags')
  await page.click('.tag-form__new-tag')
  await page.fill('.tags-modal__tag-name input', "advice")
  await page.click('.tag-form__submit')
  await expect(page.locator('.tags-modal .v-list-item-title')).toContainText('advice')

  await page.click('.tags-modal .v-list-item .tag-form__edit-tag')
  await page.fill('.tags-modal__tag-name input', "Advice")
  await page.click('.tag-form__submit')
  await expect(page.locator('.tags-modal .v-list-item-title')).toContainText('Advice')
  await expect(page.locator('.tags-modal')).not.toContainText('advice')
});

test('delete_group', async ({ page }) => {
  await page.goto('/dev/setup_group_super_admin')
  await page.click('.action-menu')
  await page.click('.action-dock__button--destroy_group')

  await page.fill('.confirm-text-field input', 'shoes')
  await page.click('.confirm-modal__submit')
  await expect(page.locator('.flash-root__message')).toContainText("This group is unavailable and will be permanently deleted after 90 days")
});

test('queues_html_group_export', async ({ page }) => {
  await page.goto('/dev/setup_group_super_admin')
  await page.click('.action-menu')
  await page.click('.action-dock__button--export_data .v-list-item-title')
  await page.click('.export-data-modal__html')
  await expect(page.locator('.confirm-modal')).toContainText('When it\'s ready you\'ll receive an email')
  await page.click('.confirm-modal__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Group data export started')
});

test('removes_group_logo_and_cover_photo', async ({ page }) => {
  await page.goto('/dev/setup_group_with_photos')
  await page.click('.action-menu')
  await page.click('.action-dock__button--edit_group')

  // both remove links should be visible
  await expect(page.locator('.group-form__remove-logo')).toBeVisible()
  await expect(page.locator('.group-form__remove-cover-photo')).toBeVisible()

  // remove logo
  await page.click('.group-form__remove-logo')
  await expect(page.locator('.flash-root__message')).toContainText('Logo removed')
  await expect(page.locator('.group-form__remove-logo')).toHaveCount(0)

  // remove cover photo
  await page.click('.group-form__remove-cover-photo')
  await expect(page.locator('.flash-root__message')).toContainText('Cover photo removed')
  await expect(page.locator('.group-form__remove-cover-photo')).toHaveCount(0)
});
