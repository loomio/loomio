module.exports = new class MembershipRequestsHelper

  loadWithMembershipRequests: ->
    browser.get('http://localhost:8000/development/setup_membership_requests')

  visitMembershipRequestsPage: ->
    element(By.css('.membership-requests-card__link')).click()

  clickApproveButton: ->
    element.all(By.css('.membership-requests-page__approve')).first().click()

  previousRequestsPanel: ->
    element(By.css('.membership-requests-page__previous-membership-requests'))

  visitGroupPage: ->
    element(By.cssContainingText('.lmo-navbar__btn-label', 'Groups')).click()
    element(By.cssContainingText('.groups-page__group-name a', 'Dirty Dancing Shoes')).click()

  clickIgnoreButton: ->
    element.all(By.css('.membership-requests-page__ignore')).first().click()

  flashSection: ->
    element(By.css('.flash-root__message'))
