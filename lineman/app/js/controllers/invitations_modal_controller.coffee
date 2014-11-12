angular.module('loomioApp').controller 'InvitationsModalController', ($scope, $modalInstance, group, InvitableService, InvitationService) ->
  $scope.group = group
  $scope.fragment = ''
  $scope.invitations = []

  invitationsModel =
    params: ->
      invitations: $scope.invitations
      group_id: $scope.group.id
      message: $scope.message

  $scope.hasInvitations = ->
    $scope.invitations.length > 0

  $scope.getInvitables = (fragment) ->
    InvitableService.fetchByNameFragment fragment, $scope.group.id, (invitables) ->
      invitables

  $scope.addInvitation = (invitation) ->
    $scope.fragment = ''
    $scope.invitations.push invitation

  $scope.submit = ->
    $scope.isDisabled = true
    InvitationService.create(invitationsModel, $scope.saveSuccess, $scope.saveError)

  $scope.cancel = ($event) ->
    $event.preventDefault()
    $modalInstance.dismiss('cancel')

  $scope.saveSuccess = () ->
    $scope.isDisabled = false
    $scope.invitations = []
    $modalInstance.close()

  $scope.saveError = (error) ->
    $scope.isDisabled = false
    $scope.errorMessages = error.error_messages

