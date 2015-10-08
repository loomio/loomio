module.exports = new class TestHelper
  loadGroupOnTrialAdmin: ->
    browser.get('http://localhost:8000/development/setup_group_on_trial_admin')

  loadGroupOnTrial: ->
    browser.get('http://localhost:8000/development/setup_group_on_trial')

  loadGroupWithExpiredTrial: ->
    browser.get('http://localhost:8000/development/setup_group_with_expired_trial')

  loadGroupWithOverdueTrial: ->
    browser.get('http://localhost:8000/development/setup_group_with_overdue_trial')

  loadGroupOnPaidPlan: ->
    browser.get('http://localhost:8000/development/setup_group_on_paid_plan')
