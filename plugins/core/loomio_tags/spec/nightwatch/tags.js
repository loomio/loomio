require('coffeescript/register')
pageHelper = require('../helpers/page_helper.coffee')

module.exports = {
  'can create a tag for a group and a discussion': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.tag-form__create-tag')
    page.fillIn('.tag-form__name', 'Tag Name')
    page.click( '.tag-form__submit')
    page.expectText('.tag-list__link', 'Tag Name')
  },

  'fetches tags when loading tags page': (test) => {
    page = pageHelper(test)

    page.loadPath('visit_tags_page')
    page.expectText('.thread-preview__text-container', 'This thread is public')
  },

  'can create a discussion tag for a discussion': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_discussion')
    page.click('.tag-form__create-tag')
    page.fillIn('.tag-form__name', 'Tag Name')
    page.click( '.tag-form__submit')
    page.pause()
    page.click('.thread-preview:first-child .thread-preview__link')

    page.click('.action-dock__button--tag_thread')
    page.click('.tag-list__toggle')
    page.click('.tag-apply-modal__submit')
    page.expectText('.lmo-badge', 'Tag Name')
  },

  'does not allow non-coordinators to create tags': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_on_paid_plan_as_non_coordinator')
    page.expectNoElement('.tag-form__create-tag')
  },

  'serializes tags in the inbox': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_inbox_with_tag')
    page.expectText('.lmo-badge', 'Tag Name')
  },

  'is visible to visitors': (test) => {
    page = pageHelper(test)

    page.loadPath('view_discussion_as_visitor_with_tags')
    page.expectText('.lmo-badge', 'Tag Name')
  }
}
