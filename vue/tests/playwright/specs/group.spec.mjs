import { test, expect } from '../fixtures.mjs';

test('displays_parent_group_in_sidebar_if_member_of_a_subgroup', async ({ lmo: page }) => {
  await page.loadPath('visit_group_as_subgroup_member')
  await page.expectText('.group-page__name', 'Point Break')
  await page.expectElement('.join-group-button')
  await page.ensureSidebar()
  await page.expectText('.sidebar__groups', 'Point Break')
});

test('links to an accessible subgroup when its parent is private', async ({ lmo: page }) => {
  await page.loadPath('visit_subgroup_with_inaccessible_parent')
  await page.expectText('.group-page__name', 'Accessible Subgroup')
  await page.ensureSidebar()
  await page.expectText('.sidebar__groups', 'Accessible Subgroup')
  await page.expectNoText('.sidebar__groups', 'Private Parent')
  await page.clickElement('.sidebar__groups a')
  await page.expectText('.group-page__name', 'Accessible Subgroup')
  await page.expectNoElement('.error-page__forbidden')
});

test('should_allow_you_to_join_an_open_group', async ({ lmo: page }) => {
  await page.loadPath('view_open_group_as_visitor')
  await page.click('.join-group-button')
  await page.signUpViaEmail('new@account.com')
  await page.pause(500)
  await page.click('.join-group-button', 500)
  await page.ensureSidebar()
  await page.expectText('.sidenav-left', 'Open Dirty Dancing Shoes')
});

test('does_not_allow_mark_as_read_or_mute', async ({ lmo: page }) => {
  await page.loadPath('view_open_group_as_visitor')
  await page.expectNoElement('.topic-preview__dismiss')
  await page.expectNoElement('.topic-preview__mute')
});

test('join_an_open_group', async ({ lmo: page }) => {
  await page.loadPath('view_open_group_as_non_member')
  await page.click('.join-group-button')
  await page.expectFlash('You are now a member')
});

test('request_to_join_a_closed_group', async ({ lmo: page }) => {
  await page.loadPath('view_closed_group_as_non_member')
  await page.click('.join-group-button')
  await page.fillIn('.membership-request-form__introduction textarea', 'I have a reason')
  await page.click('.membership-request-form__submit-btn')
  await page.expectFlash('You have requested to join')
});

test('secret_group', async ({ lmo: page }) => {
  await page.loadPath('view_secret_group_as_non_member')
  await page.expectElement('.error-page__forbidden.v-alert')
  await page.expectText('.error-page__forbidden', 'You do not have permission to view this')
  await page.expectText('.error-page__forbidden', 'You may be signed in to the wrong account')
});

test('cached secret group becomes forbidden when access is revoked', async ({ lmo: page }) => {
  await page.loadPath('setup_secret_group_with_access')
  await page.expectText('.group-page__name', 'Secret Dirty Dancing Shoes')
  await page.ensureSidebar()
  await page.expectText('.sidebar__groups', 'Secret Dirty Dancing Shoes')

  const revokeStatus = await page.execute(async () => (await fetch('/dev/revoke_secret_group_access')).status)
  expect(revokeStatus).toBe(200)

  await page.click('.sidebar__list-item-button--recent')
  await page.waitFor('.dashboard-page')
  await page.ensureSidebar()
  await page.pause(300)
  await page.clickElement('.sidebar__groups a')
  await page.expectElement('.error-page__forbidden.v-alert')
  await page.expectText('.error-page__forbidden', 'You do not have permission to view this')
  await page.expectNoElement('.group-page__name')
});

test('keeps the routed panel mounted while changing groups', async ({ lmo: page }) => {
  await page.loadPath('setup_group_route_transitions')
  await page.ensureSidebar()
  await page.expectText('.sidebar__groups', 'Dirty Dancing Shoes')
  await page.expectText('.sidebar__groups', 'Point Break')

  await page.execute(() => {
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

  await page.execute(() => {
    const clickGroup = name => {
      const links = Array.from(document.querySelectorAll('.sidebar__groups > .v-list-item'))
      links.find(link => link.textContent.includes(name)).click()
    }
    clickGroup('Point Break')
  })

  await page.expectText('.group-page__name', 'Point Break')
  await page.expectElement('.discussions-panel')
  await page.execute(() => {
    document.querySelector('.discussions-panel').dataset.e2eInstance = 'original'
  })
  await page.pause(500)
  expect(await page.execute(() => document.querySelector('.discussions-panel').dataset.e2eInstance),
    'does not remount the routed panel after refreshing the group').toBe('original')
  expect(await page.execute(() => window.__groupRouteRendererErrors),
    'does not raise Vue renderer errors while changing groups').toEqual([])
});

test('filters_group_polls_by_status_type_and_tag', async ({ lmo: page }) => {
  await page.loadPath('setup_group_poll_filters')
  await page.click('.group-page-polls-tab')
  await page.expectText('.polls-panel', 'Open important proposal needing a vote', 20000)
  await page.expectText('.polls-panel', 'Open other poll already voted on')
  await page.expectText('.polls-panel', 'Closed untagged poll')

  await page.click('.polls-panel__status-filter')
  await page.pause(200)
  await page.click('.v-overlay--active .polls-panel__status-active')
  await page.expectText('.polls-panel', 'Open important proposal needing a vote')
  await page.expectText('.polls-panel', 'Open other poll already voted on')
  await page.expectNoText('.polls-panel', 'Closed untagged poll')

  await page.click('.polls-panel__status-filter')
  await page.pause(200)
  await page.click('.v-overlay--active .polls-panel__status-vote')
  await page.expectText('.polls-panel', 'Open important proposal needing a vote')
  await page.expectNoText('.polls-panel', 'Open other poll already voted on')
  await page.expectNoText('.polls-panel', 'Closed untagged poll')

  await page.click('.polls-panel__status-filter')
  await page.pause(200)
  await page.click('.v-overlay--active .polls-panel__status-closed')
  await page.expectText('.polls-panel', 'Closed untagged poll')
  await page.expectNoText('.polls-panel', 'Open important proposal needing a vote')
  await page.expectNoText('.polls-panel', 'Open other poll already voted on')

  await page.click('.polls-panel__status-filter')
  await page.pause(200)
  await page.click('.v-overlay--active .polls-panel__status-any')
  await page.expectText('.polls-panel', 'Open important proposal needing a vote')
  await page.expectText('.polls-panel', 'Open other poll already voted on')
  await page.expectText('.polls-panel', 'Closed untagged poll')

  await page.click('.polls-panel__type-filter')
  await page.pause(200)
  await page.click('.v-overlay--active .polls-panel__type-option[data-poll-type="proposal"]')
  await page.expectText('.polls-panel', 'Open important proposal needing a vote')
  await page.expectNoText('.polls-panel', 'Open other poll already voted on')
  await page.expectNoText('.polls-panel', 'Closed untagged poll')

  await page.click('.polls-panel__type-filter')
  await page.pause(200)
  await page.click('.v-overlay--active .polls-panel__type-any')
  await page.expectText('.polls-panel', 'Open other poll already voted on')
  await page.expectText('.polls-panel', 'Closed untagged poll')

  await page.click('.tags-filter-menu__button')
  await page.pause(200)
  await page.click('.v-overlay--active .tags-filter-menu__tag[data-tag-name="Important"]')
  await page.expectText('.polls-panel', 'Open important proposal needing a vote')
  await page.expectNoText('.polls-panel', 'Open other poll already voted on')
  await page.expectNoText('.polls-panel', 'Closed untagged poll')

  await page.click('.tags-filter-menu__button')
  await page.pause(200)
  await page.click('.v-overlay--active .tags-filter-menu__all-tags')
  await page.expectText('.polls-panel', 'Open important proposal needing a vote')
  await page.expectText('.polls-panel', 'Open other poll already voted on')
  await page.expectText('.polls-panel', 'Closed untagged poll')
});

test('displays_threads_from_subgroups_in_the_discussions_card', async ({ lmo: page }) => {
  await page.loadPath('setup_group_with_subgroups')
  await page.expectText('.discussions-panel__list', 'Vaya con dios', 20000)
});

test('closed_subgroup_whose_parent_members_can_see_private_threads', async ({ lmo: page }) => {
  await page.loadPath('setup_subgroup_with_parent_member_visibility')
  await page.pause(2000)
  await page.expectText('.discussions-panel__list', 'Vaya con dios', 20000)
});

test('starts_a_secret_group', async ({ lmo: page }) => {
  await page.loadPath('setup_dashboard')
  await page.ensureSidebar()

  await page.click('.sidebar-start-group')

  await page.fillIn('.group-form__name input', 'Secret please')
  await page.click('.group-form__category-select .v-field')
  await page.click('.v-overlay .v-select__content .v-list-item')
  await page.click('.group-form__submit-button')
  await page.expectFlash('Group started')
});

test('open_subgroup', async ({ lmo: page }) => {
  await page.loadPath('setup_open_group')
  await page.ensureSidebar()
  await page.click('.sidebar-start-subgroup')

  await page.fillIn('#group-name', 'Open please')
  await page.click('.group-form__privacy-open')
  await page.expectElement('.group-form__joining')
  await page.click('.group-form__submit-button')
  await page.expectFlash('Group started')

  await page.click('.action-menu')
  await page.click('.action-dock__button--edit_group')
  await page.pause(200)
  await page.click('.group-form__permissions-tab')

  await page.expectNoElement('.group-form__parent-members-can-see-discussions')
});

test('closed_subgroup', async ({ lmo: page }) => {
  await page.loadPath('setup_open_group')
  await page.ensureSidebar()
  await page.click('.sidebar-start-subgroup')

  await page.fillIn('#group-name', 'Closed please')
  await page.click('.group-form__privacy-closed')
  await page.expectElement('.group-form__joining')
  await page.expectElement('.group-form__membership-granted-upon-request')
  await page.click('.group-form__submit-button')
  await page.expectFlash('Group started')

  await page.click('.action-menu')
  await page.click('.action-dock__button--edit_group')
  await page.click('.group-form__permissions-tab')

  await page.expectElement('.group-form__parent-members-can-see-discussions')
});

test('secret_subgroup', async ({ lmo: page }) => {
  await page.loadPath('setup_open_group')
  await page.ensureSidebar()
  await page.click('.sidebar-start-subgroup')
  await page.fillIn('#group-name', 'Secret please')
  await page.click('.group-form__privacy-secret')
  await page.expectNoElement('.group-form__joining')
  await page.click('.group-form__submit-button')
  await page.expectFlash('Group started')

  await page.click('.action-menu')
  await page.click('.action-dock__button--edit_group')
  await page.click('.group-form__permissions-tab')

  await page.expectNoElement('.group-form__parent-members-can-see-discussions')
});

test('successfully_edits_group_name_and_description', async ({ lmo: page }) => {
  await page.loadPath('setup_group')
  await page.click('.action-menu')
  await page.click('.action-dock__button--edit_group')

  await page.fillIn('#group-name', 'Clean Dancing Shoes')
  await page.fillIn('.group-form__group-description .lmo-textarea textarea', 'Dusty sandles')
  await page.click('.group-form__submit-button')

  await page.pause(500)
  await page.expectText('.group-page__name', 'Clean Dancing Shoes')
});

  // TODO reenable when clearValue bug is fixed
  // 'displays_a_validation_error_when_name_is_blank': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_group')
  //   page.click('.action-dock__button--button')
  //   page.click('.action-dock__button--edit-group-link')
  //   page.fillIn('.group-form__name input', '') // TODO: GK: setValue is not clearing the input
  //   page.click('.group-form__submit-button')
  //   page.pause()
  //   page.expectText('.lmo-validation-error', "can't be blank")
  // },

  // 'can_be_a_very_open_group': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_group')
  //
  //   page.click('.action-menu')
  //   page.click('.action-dock__button--edit_group')
  //
  //   page.click('.group-form__privacy-tab')
  //   page.click('.group-form__privacy-open')
  //   page.click('.group-form__membership-granted-upon-request')
  //
  //   page.click('.group-form__permissions-tab')
  //   page.click('.group-form__members-can-create-subgroups label')
  //   page.click('.group-form__submit-button')
  //
  //   // confirm privacy change
  //   page.acceptConfirm()
  //
  //   // reopen form
  //   page.click('.action-menu')
  //   page.click('.action-dock__button--edit_group')
  //
  //
  //   // confirm the settings have stuck
  //   page.click('.group-form__privacy-tab')
  //   page.expectElement('.group-form__privacy-open input[aria-checked="true"]')
  //   page.click('.group-form__permissions-tab')
  //   page.expectElement('.group-form__membership-granted-upon-request input[aria-checked="true"]')
  //   page.expectElement('.group-form__members-can-add-members input[aria-checked="true"]')
  //   page.expectElement('.group-form__members-can-create-subgroups input[aria-checked="true"]')
  // },

  // 'can_be_a_very_locked_down_group': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_group')
  //   page.click('.action-menu')
  //   page.click('.action-dock__button--edit_group')
  //
  //   page.click('.group-form__privacy-tab')
  //   page.click('.group-form__privacy-secret')
  //   page.click('.group-form__permissions-tab')
  //
  //   page.click('.group-form__members-can-start-discussions label')
  //   page.click('.group-form__members-can-edit-discussions label')
  //   page.click('.group-form__members-can-edit-comments label')
  //   page.click('.group-form__members-can-raise-motions label')
  //   page.click('.group-form__members-can-vote label')
  //
  //   page.click('.group-form__submit-button')
  //
  //   // confirm privacy change
  //   page.acceptConfirm()
  //
  //   page.pause(500)
  //
  //   // reopen form
  //   page.click('.action-menu', 500)
  //   page.click('.action-dock__button--edit_group', 500)
  //
  //   // confirm the settings have stuck
  //   page.click('.group-form__privacy-tab', 500)
  //   page.expectElement('.group-form__privacy-secret input[aria-checked="true"]')
  //
  //   page.click('.group-form__permissions-tab')
  //   page.expectNoElement('.group-form__members-can-start-discussions input[aria-checked="true"]')
  //   page.expectNoElement('.group-form__members-can-edit-discussions input[aria-checked="true"]')
  //   page.expectNoElement('.group-form__members-can-edit-comments input[aria-checked="true"]')
  //   page.expectNoElement('.group-form__members-can-raise-motions input[aria-checked="true"]')
  //   page.expectNoElement('.group-form__members-can-vote input[aria-checked="true"]')
  // },

test('allows_group_members_to_leave_the_group', async ({ lmo: page }) => {
  await page.loadPath('setup_group_with_multiple_coordinators')
  await page.click('.action-menu')
  await page.click('.action-dock__button--leave_group')
  await page.click('.confirm-modal__submit')
  await page.expectFlash('You have left this group')
  await page.expectText('.dashboard-page__empty', 'Welcome! You are not a member of any groups yet.')
});

test('starts_a_discussion', async ({ lmo: page }) => {
  await page.loadPath('setup_group')
  await page.click('.discussions-panel__new-topic-button')
  await page.click('.discussion-templates--template')
  await page.fillIn('#discussion-title', 'Nobody puts baby in a corner')
  await page.fillIn('.discussion-form .lmo-textarea div[contenteditable=true]', "I've had the time of my life")
  await page.fillIn('.discussion-form .tags-field__input input', '#important')
  await page.click('.discussion-form__submit')
  await page.expectFlash("Discussion started")
  await page.expectText('.context-panel__heading', 'Nobody puts baby in a corner' )
  await page.expectText('.context-panel__description', "I've had the time of my life" )
  await page.expectText('.tags-display', '#important')
});

test('lets_you_change_membership_volume', async ({ lmo: page }) => {
  await page.loadPath('setup_group')
  await page.click('.action-menu')
  await page.click('.action-dock__button--change_volume')

  await page.click('.volume-loud label')
  await page.click('.change-volume-form__submit')
  await page.expectFlash('Notification settings updated')
});

test('creates_and_deletes_category_tag', async ({ lmo: page }) => {
  await page.loadPath('setup_group')
  await page.click('.action-menu')
  await page.pause(200)
  await page.click('.action-dock__button--edit_tags')
  await page.click('.tag-form__new-tag')
  await page.fillIn('.tags-modal__tag-name input', "#important")
  await page.click('.tag-form__submit')
  await page.expectText('.tags-modal .v-list-item-title', '#important' )
  await page.click('.tags-modal .v-list-item .tag-form__delete')
  await page.expectText('.confirm-modal', 'Delete tag')
  await page.click('.confirm-modal__submit')
  await page.expectFlash('Tag deleted')
  await page.expectNoText('.tags-modal', '#important')
});

test('renames_category_tag', async ({ lmo: page }) => {
  await page.loadPath('setup_group')
  await page.click('.action-menu')
  await page.pause(200)
  await page.click('.action-dock__button--edit_tags')
  await page.click('.tag-form__new-tag')
  await page.fillIn('.tags-modal__tag-name input', "#important")
  await page.click('.tag-form__submit')
  await page.expectText('.tags-modal .v-list-item-title', '#important')

  await page.click('.tags-modal .v-list-item .tag-form__edit-tag')
  await page.clearField('.tags-modal__tag-name input')
  await page.fillIn('.tags-modal__tag-name input', "#renamed")
  await page.click('.tag-form__submit')
  await page.expectText('.tags-modal .v-list-item-title', '#renamed')
  await page.expectNoText('.tags-modal', '#important')
});

test('renames_category_tag_case_only', async ({ lmo: page }) => {
  await page.loadPath('setup_group')
  await page.click('.action-menu')
  await page.pause(200)
  await page.click('.action-dock__button--edit_tags')
  await page.click('.tag-form__new-tag')
  await page.fillIn('.tags-modal__tag-name input', "advice")
  await page.click('.tag-form__submit')
  await page.expectText('.tags-modal .v-list-item-title', 'advice')

  await page.click('.tags-modal .v-list-item .tag-form__edit-tag')
  await page.clearField('.tags-modal__tag-name input')
  await page.fillIn('.tags-modal__tag-name input', "Advice")
  await page.click('.tag-form__submit')
  await page.expectText('.tags-modal .v-list-item-title', 'Advice')
  await page.expectNoText('.tags-modal', 'advice')
});

test('delete_group', async ({ lmo: page }) => {
  await page.loadPath('setup_group_super_admin')
  await page.click('.action-menu')
  await page.click('.action-dock__button--destroy_group')

  await page.fillIn('.confirm-text-field input', 'shoes')
  await page.click('.confirm-modal__submit')
  await page.expectFlash("This group is unavailable and will be permanently deleted after 90 days")
});

test('queues_html_group_export', async ({ lmo: page }) => {
  await page.loadPath('setup_group_super_admin')
  await page.click('.action-menu')
  await page.click('.action-dock__button--export_data .v-list-item-title')
  await page.clickElement('.export-data-modal__html')
  await page.expectText('.confirm-modal', 'When it\'s ready you\'ll receive an email')
  await page.click('.confirm-modal__submit')
  await page.expectFlash('Group data export started')
});

test('removes_group_logo_and_cover_photo', async ({ lmo: page }) => {
  await page.loadPath('setup_group_with_photos')
  await page.click('.action-menu')
  await page.click('.action-dock__button--edit_group')
  await page.pause(500)

  // both remove links should be visible
  await page.expectElement('.group-form__remove-logo')
  await page.expectElement('.group-form__remove-cover-photo')

  // remove logo
  await page.click('.group-form__remove-logo')
  await page.expectFlash('Logo removed')
  await page.expectNoElement('.group-form__remove-logo')

  // remove cover photo
  await page.click('.group-form__remove-cover-photo')
  await page.expectFlash('Cover photo removed')
  await page.expectNoElement('.group-form__remove-cover-photo')
});
