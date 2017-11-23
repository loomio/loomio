describe 'Joining group', ->

  page = require './helpers/page_helper.coffee'

  # new_discussion
  describe 'create', ->
    page.loadPath 'setup_group'
    page.click '.discussions-card__new-thread-button'
    page.fillIn '.discussion-form__title-input', 'Immannounce dis'
    page.click '.discussion-form__submit'
    page.expectFlash 'Thread started'
    page.expectElement '.announcement-form'
    page.expectText '.announcement-form__chips', 'Dirty Dancing Shoes'
    page.click '.announcement-form__submit'
    page.expectFlash '2 notifications sent'

  describe 'poll_created', ->
    page.loadPath 'setup_discussion'
    page.clickFirst '.decision-tools-card__poll-type'
    page.fillIn '.poll-common-form-fields__title', 'Immanounce dis too'
    page.click '.poll-common-form__submit'
    page.expectFlash 'Proposal started'
    page.expectElement '.announcement-form'
    page.expectText '.announcement-form__chips', 'Dirty Dancing Shoes'
    page.fillIn 'md-autocomplete input', 'jenn'
    page.click '.announcement-chip'
    page.expectText '.announcement-form__chips', 'Jennifer Grey'
    page.click '.announcement-form__submit'
    page.expectFlash '3 notifications sent'

  describe 'outcome_created', ->
    page.loadPath 'polls/test_proposal_poll_closed'
    page.click '.poll-common-set-outcome-panel__submit'
    page.fillIn '.poll-common-outcome-form__statement textarea', 'Immannounce all yall'
    page.click '.poll-common-outcome-form__submit'
    page.expectFlash 'Outcome created'
    page.expectElement '.announcement-form'
    page.fillIn 'md-autocomplete input', 'test@example.com'
    page.click '.announcement-chip'
    page.expectText '.announcement-form__chips', 'test@example.com'
    page.click '.announcement-form__submit'
    page.expectFlash '1 notifications sent'
