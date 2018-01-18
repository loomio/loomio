Records      = require 'shared/services/records.coffee'
EventBus     = require 'shared/services/event_bus.coffee'
FlashService = require 'shared/services/flash_service.coffee'
I18n         = require 'shared/services/i18n.coffee'

{ registerKeyEvent } = require 'shared/helpers/keyboard.coffee'

angular.module('loomioApp').directive 'pollCommonShareEmailForm', ->
  scope: {poll: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/share/email_form/poll_common_share_email_form.html'
  controller: ['$scope', ($scope) ->
    $scope.newEmail = ''

    $scope.addIfValid = ->
      $scope.emailValidationError = null
      $scope.checkEmailNotEmpty()
      $scope.checkEmailValid()
      $scope.checkEmailAvailable()
      $scope.add() unless $scope.emailValidationError

    $scope.add = ->
      return unless $scope.newEmail.length > 0
      $scope.poll.customFields.pending_emails.push($scope.newEmail)
      $scope.newEmail = ''
      $scope.emailValidationError = null

    $scope.submit = ->
      $scope.emailValidationError = null
      $scope.checkEmailValid()
      $scope.checkEmailAvailable()
      if !$scope.emailValidationError
        $scope.add()
        $scope.poll.inviteGuests().then ->
          FlashService.success 'poll_common_share_form.guests_invited', count: $scope.poll.customFields.pending_emails.length
          EventBus.emit $scope, '$close'

    $scope.checkEmailNotEmpty = ->
      if $scope.newEmail.length <= 0
        $scope.emailValidationError = I18n.t('poll_common_share_form.email_empty')

    $scope.checkEmailValid = ->
      if $scope.newEmail.length > 0 && !$scope.newEmail.match(/[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/g)
        $scope.emailValidationError = I18n.t('poll_common_share_form.email_invalid')

    $scope.checkEmailAvailable = ->
      if _.contains($scope.poll.customFields.pending_emails, $scope.newEmail)
        $scope.emailValidationError = I18n.t('poll_common_share_form.email_exists', email: $scope.newEmail)

    $scope.remove = (email) ->
      _.pull($scope.poll.customFields.pending_emails, email)

    registerKeyEvent $scope, 'pressedEnter', $scope.add, (active) ->
      active.classList.contains('poll-common-share-form__add-option-input')
  ]
