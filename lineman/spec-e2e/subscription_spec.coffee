page = require './helpers/page_helper.coffee'

describe 'Subscription flow', ->
  describe 'new group with 30 day trial', ->

    it 'displays the trial card to on group page for coordinators only', ->
      page.loadPath('setup_group_on_trial_admin')
      page.expectText('.trial-card', 'You can pick a pricing plan')

    it 'does not display the trial card for non-coordinators', ->
      page.loadPath('setup_group_on_trial')
      page.expectNoElement('.trial-card')

    it 'lets coordinator choose gift plan', ->
      page.loadPath('setup_group_on_trial_admin')
      page.click('.trial-card__choose-plan-button',
                 '.choose-plan-modal__select-button--gift')
      page.expectText('.confirm-gift-plan-modal',
                      'Gift plan selected')
      page.click('.confirm-gift-plan-modal__submit-button')
      page.expectText('.gift-card', 'GIFT PLAN')

  describe 'group with expired trial', ->

    it 'displays a trial card telling coordinators their trial has expired', ->
      page.loadPath('setup_group_with_expired_trial')
      page.expectText('.trial-card', "you'll need to pick a pricing plan that suits." )

    it 'displays the nag modal when trial expired more than 15 days ago', ->
      page.loadPath('setup_group_with_overdue_trial')
      page.expectText('.choose-plan-modal', 'please choose a payment plan')

  describe 'group on paid plan', ->

    it 'hides trial card and offers subscription management', ->
      page.loadPath('setup_group_on_paid_plan')
      page.expectNoElement('.trial-card')
      page.click('.group-page-actions__button')
      page.expectElement('.group-page-actions__manage-subscription-link')
