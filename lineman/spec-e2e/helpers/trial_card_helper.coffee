module.exports = new class TrialCardHelper

  card: ->
    element(By.css('.trial-card'))

  cardText: ->
    element(By.css('.trial-card')).getText()

  clickChoosePricingPlanButton: ->
    element(By.css('.trial-card__choose-plan-button')).click()

  selectGiftPlan: ->
    element(By.css('.choose-plan-modal__select-button--gift')).click()

  confirmGiftPlanText: ->
    element(By.css('.modal-confirm-gift-plan-modal')).getText()

  clickConfirmGiftPlanOk: ->
    element(By.css('.confirm-gift-plan-modal__submit-button')).click()

  giftCardText: ->
    element(By.css('.gift-card')).getText()

  choosePlanModalText: ->
    element(By.css('.choose-plan-modal')).getText()

  clickRemindMeLater: ->
    element(By.css('.choose-plan-modal__cancel')).click()

  manageSubscriptionLink: ->
    element(By.css('.group-page-actions__manage-subscription-link'))
