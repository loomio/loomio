module.exports = new class MembershipsHelper

  visitMembershipsPage: ->
    element(By.css('.members-card__manage-members')).click()

  searchInput: ->
    element(By.css('.membership-page__search-filter'))

  fillInSearchInput: (name) ->
    @searchInput().clear().sendKeys(name)

  clickRemoveLink: ->
    element(By.css('.memberships-panel__remove')).click()

  confirmRemoveAction: ->
    element(By.css('.memberships-page__remove-membership-confirm')).click()

  currentMembershipRow: ->
    element(By.css('.memberships-page__membership'))

  clearSearchInput: ->
    @searchInput().clear()

  membershipsTable: ->
    element(By.css('.memberships-panel')).getText()

  coordinatorCheckbox: ->
    element(By.css('.memberships-panel__toggle-coordinator'))

  checkCoordinatorCheckbox: ->
    @coordinatorCheckbox().click()

  currentCoordinatorsCount: ->
    element.all(By.css('.user-avatar--coordinator')).count()

  membershipsPageHeader: ->
    element(By.css('.memberships-page__memberships h2'))

  makeJenniferCoordinator: ->
    @fillInSearchInput('Jennifer')
    @checkCoordinatorCheckbox()

  confirmRemoval: ->
    browser.switchTo().alert().accept()
