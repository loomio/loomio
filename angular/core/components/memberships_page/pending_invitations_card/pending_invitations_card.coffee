angular.module('loomioApp').directive 'pendingInvitationsCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/memberships_page/pending_invitations_card/pending_invitations_card.html'
  replace: true
  controller: ($scope, CurrentUser, Records, ModalService, CancelInvitationForm, AppConfig) ->
    $scope.canSeeInvitations = ->
      CurrentUser.isAdminOf($scope.group)

    if $scope.canSeeInvitations()
      Records.invitations.fetchPendingByGroup($scope.group.key)

    $scope.baseUrl = AppConfig.baseUrl

    $scope.openCancelForm = (invitation) ->
      ModalService.open CancelInvitationForm, invitation: -> invitation

    $scope.invitationCreatedAt = (invitation) ->
      moment(invitation.createdAt).format('DD MMM YY')
