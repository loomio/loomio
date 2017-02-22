module.exports = new class MembershipRequestsHelper

  loadWithMembershipRequests: ->
    browser.get('dev/setup_membership_requests')

  clickMembershipRequestsLink: ->
    element(By.css('.membership-requests-card__link')).click()

  clickApproveButton: ->
    element.all(By.css('.membership-requests-page__approve')).first().click()

  pendingRequestsPanel: ->
    element(By.css('.membership-requests-page__pending-requests')).getText()

  previousRequestsPanel: ->
    element(By.css('.membership-requests-page__previous-requests')).getText()

  clickGroupName: ->
    element(By.cssContainingText('.sidebar__list-item-button--group', 'Dirty Dancing Shoes')).click()

  clickIgnoreButton: ->
    element.all(By.css('.membership-requests-page__ignore')).first().click()

  approveAllRequests: ->
    element.all(By.css('.membership-requests-page__approve')).click()
