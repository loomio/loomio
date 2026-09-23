pageHelper = require('../helpers/pageHelper')

module.exports = {
  'browse_page_displays_templates': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion_template_browse')
    page.expectText('.discussion-templates-browse-page', 'Advice process')
    page.expectText('.discussion-templates-browse-page', 'Consent process')
    test.end()
  },

  'nonmember_can_submit_a_nomination_from_a_group_template': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_nonmember_nomination')
    page.expectText('.group-page__name', 'Dirty Dancing Shoes')
    page.expectNoElement('.join-group-button')
    page.click('.discussions-panel__new-topic-button')
    page.expectText('.discussion-templates-page', 'Nominate a candidate')
    page.click('.discussion-templates--template')
    page.expectText('.discussion-form', 'Who are you nominating, and for which position?')
    page.expectNoElement('.common-notify-fields')
    page.expectNoElement('.flash-root__message')
    page.fillIn('.discussion-form__title-input input', 'Sam Rivera — Board chair')
    page.click('.discussion-form__submit')
    page.expectFlash('Discussion started')
    page.expectText('.context-panel__heading', 'Sam Rivera — Board chair')
    page.expectText('.context-panel__description', 'Why is this person suitable?')
    page.expectNoElement('.action-dock__button--announce_thread')
  }
}
