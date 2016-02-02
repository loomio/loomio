module.exports = new class MembershipRequestsHelper

  loadWithMembershipRequests: ->
    browser.get('development/setup_membership_requests')

  clickMembershipRequestsLink: ->
    element(By.css('.membership-requests-card__link')).click()

  clickApproveButton: ->
    element.all(By.css('.membership-requests-page__approve')).first().click()

  pendingRequestsPanel: ->
    element(By.css('.membership-requests-page__pending-requests')).getText()

  previousRequestsPanel: ->
    element(By.css('.membership-requests-page__previous-requests')).getText()

  clickNavbarGroupLink: ->
    element(By.cssContainingText('.lmo-navbar__btn-label', 'Groups')).click()

  clickGroupName: ->
    element(By.cssContainingText('.groups-page__parent-group-name a', 'Dirty Dancing Shoes')).click()

  clickIgnoreButton: ->
    element.all(By.css('.membership-requests-page__ignore')).first().click()

  approveAllRequests: ->
    element.all(By.css('.membership-requests-page__approve')).click()
