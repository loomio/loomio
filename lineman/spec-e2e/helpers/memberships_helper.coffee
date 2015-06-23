module.exports = new class MembershipsHelper

  visitMembershipsPage: ->
    element(By.css('.members-card__manage-members a')).click()

  clickRemoveLink: ->
    element.all(By.css('.memberships-page__remove-link')).last().click()

  currentMembershipsCount: ->
    element.all(By.css('.memberships-page__membership')).count()

  disabledCoordinatorCheckbox: ->
    element.all(By.css('.memberships-page__make-coordinator')).first()

  enabledCoordinatorCheckbox: ->
    element.all(By.css('.memberships-page__make-coordinator')).last()

  checkCoordinatorCheckbox: ->
    @enabledCoordinatorCheckbox().click()

  currentCoordinatorsCount: ->
    element.all(By.css('.coordinator')).count()
