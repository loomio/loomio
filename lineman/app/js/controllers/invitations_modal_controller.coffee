angular.module('loomioApp').controller 'InvitationsModalController', ($scope, $modalInstance, group, InvitableService) ->
  $scope.group = group
  $scope.fragment = ''
  $scope.invitations = []

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
    InvitableService.sendInvitations($scope.invitations, $scope.saveSuccess, $scope.saveError)

  $scope.cancel = ($event) ->
    $event.preventDefault()
    $modalInstance.dismiss('cancel')

  $scope.saveSuccess = () ->
    $scope.isDisabled = false
    $modalInstance.close()

  $scope.saveError = (error) ->
    $scope.isDisabled = false
    $scope.errorMessages = error.error_messages

