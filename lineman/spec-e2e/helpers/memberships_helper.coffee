module.exports = new class MembershipsHelper

  visitMembershipsPage: ->
    element(By.css('.members-card__manage-members a')).click()

  searchInput: ->
    element(By.css('.membership-page__search-filter'))

  fillInSearchInput: (name) ->
    @searchInput().sendKeys(name)

  clickRemoveLink: ->
    element(By.css('.memberships-page__remove-link')).click()

  confirmRemoveAction: ->
    element(By.css('.memberships-page__remove-membership-confirm')).click()

  currentMembershipRow: ->
    element(By.css('.memberships-page__membership'))

  clearSearchInput: ->
    @searchInput().clear()

  membershipsTable: ->
    element(By.css('.memberships-page__memberships'))

  coordinatorCheckbox: ->
    element(By.css('.memberships-page__make-coordinator'))

  checkCoordinatorCheckbox: ->
    @coordinatorCheckbox().click()

  currentCoordinatorsCount: ->
    element.all(By.css('.coordinator')).count()

  membershipsPageHeader: ->
    element(By.css('.memberships-page__memberships h2'))
