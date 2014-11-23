angular.module('loomioApp').controller 'GroupInvitationsFormController', ($scope, $modalInstance, group, InvitableService, InvitationService) ->
  $scope.group = group
  $scope.fragment = ''
  $scope.invitations = []
  $scope.showContactImportMessage = true

  invitationsModel =
    params: ->
      invitations: $scope.invitations
      group_id: $scope.group.id
      message: $scope.message

  $scope.dismissContactImportMessage = ->
    $scope.showContactImportMessage = false

  $scope.hasInvitations = ->
    $scope.invitations.length > 0

  $scope.getInvitables = (fragment) ->
    InvitableService.fetchByNameFragment fragment, $scope.group.id, (invitables) ->
      invitables.concat $scope.currentEmailInput()

  $scope.currentEmailInput = ->
    if angular.element('#invitable-email').hasClass('ng-valid-email')
      [{ name: $scope.fragment, type: 'Email', email: $scope.fragment }]
    else
      []

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

