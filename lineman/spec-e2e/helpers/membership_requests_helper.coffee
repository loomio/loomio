module.exports = new class MembershipRequestsHelper

  loadWithMembershipRequests: ->
    browser.get('http://localhost:8000/development/setup_membership_requests')

  clickMembershipRequestsLink: ->
    element(By.css('.membership-requests-card__link')).click()

  clickApproveButton: ->
    element.all(By.css('.membership-requests-page__approve')).first().click()

  previousRequestsPanel: ->
    element(By.css('.membership-requests-page__previous-membership-requests'))

  clickNavbarGroupLink: ->
    element(By.cssContainingText('.lmo-navbar__btn-label', 'Groups')).click()

  clickGroupName: ->
    element(By.cssContainingText('.groups-page__parent-group-name a', 'Dirty Dancing Shoes')).click()

  clickIgnoreButton: ->
    element.all(By.css('.membership-requests-page__ignore')).first().click()
