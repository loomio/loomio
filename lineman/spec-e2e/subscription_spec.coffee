describe 'Subscription flow', ->

  trialCard = require './helpers/trial_card_helper.coffee'
  testHelper = require './helpers/test_helper.coffee'
  groupsHelper = require './helpers/groups_helper.coffee'

  describe 'signup from front page', ->
    # to do

  describe 'new group with 30 day trial', ->

    it 'displays the trial card to on group page for coordinators only', ->
      testHelper.loadGroupOnTrialAdmin()
      expect(trialCard.cardText()).toContain('You can pick a pricing plan')

    it 'does not display the trial card for non-coordinators', ->
      testHelper.loadGroupOnTrial()
      expect(trialCard.card().isPresent()).toBe(false)

    it 'lets coordinator choose gift plan', ->
      testHelper.loadGroupOnTrialAdmin()
      trialCard.clickChoosePricingPlanButton()
      trialCard.selectGiftPlan()
      expect(trialCard.confirmGiftPlanText()).toContain('Gift plan selected')
      trialCard.clickConfirmGiftPlanOk()
      expect(trialCard.giftCardText()).toContain('GIFT PLAN')

  describe 'group with expired trial', ->

    it 'displays a trial card telling coordinators their trial has expired', ->
      testHelper.loadGroupWithExpiredTrial()
      expect(trialCard.cardText()).toContain("If you'd like to keep using it, you'll need to pick a pricing plan that suits.")

    it 'displays the nag modal when trial expired more than 15 days ago', ->
      testHelper.loadGroupWithOverdueTrial()
      expect(trialCard.choosePlanModalText()).toContain('To continue using Loomio, please choose a payment plan')
      # trialCard.clickRemindMeLater()
      # groupsHelper.visitGroupsPage()
      # groupsHelper.visitFirstGroup()
      # expect(trialCard.choosePlanModalText().isPresent()).toBe(false)

  describe 'group on paid plan', ->

    beforeEach ->
      testHelper.loadGroupOnPaidPlan()

    it 'does not display the trial card', ->
      expect(trialCard.card().isPresent()).toBe(false)

    it 'lets coordinators manage their subscription', ->
      groupsHelper.openMemberOptionsDropdown()
      expect(trialCard.manageSubscriptionLink().isPresent()).toBe(true)
