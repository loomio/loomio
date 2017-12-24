Session      = require 'shared/services/session.coffee'
Records      = require 'shared/services/records.coffee'
FlashService = require 'shared/services/flash_service.coffee'
ModalService = require 'shared/services/modal_service.coffee'

angular.module('loomioApp').directive 'pendingInvitationsCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/memberships_page/pending_invitations_card/pending_invitations_card.html'
  replace: true
  controller: ($scope) ->
    $scope.canSeeInvitations = ->
      Session.user().isAdminOf($scope.group)

    if $scope.canSeeInvitations()
      Records.invitations.fetchPendingByGroup($scope.group.key, per: 1000)

    $scope.openCancelForm = (invitation) ->
      ModalService.open 'CancelInvitationForm', invitation: -> invitation

    $scope.invitationCreatedAt = (invitation) ->
      moment(invitation.createdAt).format('DD MMM YY')

    $scope.resend = (invitation) ->
      invitation.resending = true
      invitation.resend().then ->
        FlashService.success 'common.action.resent'
      .finally -> invitation.resending = false

    $scope.copied = ->
      FlashService.success 'common.copied'
