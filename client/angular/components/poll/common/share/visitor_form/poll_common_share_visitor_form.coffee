Records      = require 'shared/services/records.coffee'
FlashService = require 'shared/services/flash_service.coffee'

{ registerKeyEvent } = require 'angular/helpers/keyboard.coffee'

angular.module('loomioApp').directive 'pollCommonShareVisitorForm', ($translate) ->
  scope: {poll: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/share/visitor_form/poll_common_share_visitor_form.html'
  controller: ($scope) ->

    $scope.invitations = ->
      Records.invitations.find(groupId: $scope.poll.guestGroupId)

    $scope.init = ->
      Records.invitations.fetch(params: {group_id: $scope.poll.guestGroupId})
      $scope.newInvitation = Records.invitations.build(recipientEmail: '', groupId: $scope.poll.guestGroupId, intent: 'join_poll')
    $scope.init()

    $scope.submit = ->
      if $scope.newInvitation.recipientEmail.length <= 0
        $scope.emailValidationError = $translate.instant('poll_common_share_form.email_empty')
      else if _.contains(_.pluck($scope.invitations(), 'recipientEmail'), $scope.newInvitation.recipientEmail)
        $scope.emailValidationError = $translate.instant('poll_common_share_form.email_exists', email: $scope.newInvitation.recipientEmail)
      else if !$scope.newInvitation.recipientEmail.match(/[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/g)
        $scope.emailValidationError = $translate.instant('poll_common_share_form.email_invalid')
      else
        $scope.emailValidationError = null
        $scope.newInvitation.save().then ->
          FlashService.success 'poll_common_share_form.email_invited', email: $scope.newInvitation.recipientEmail
          $scope.init()
          document.querySelector('.poll-common-share-form__add-option-input').focus()

    $scope.revoke = (visitor) ->
      visitor.destroy()
             .then ->
               visitor.revoked = true
               FlashService.success "poll_common_share_form.guest_revoked", email: visitor.email

    $scope.remind = (visitor) ->
      visitor.remind($scope.poll).then ->
        visitor.reminded = true
        FlashService.success 'poll_common_share_form.email_invited', email: visitor.email

    registerKeyEvent $scope, 'pressedEnter', $scope.submit, (active) ->
      active.classList.contains('poll-common-share-form__add-option-input')
