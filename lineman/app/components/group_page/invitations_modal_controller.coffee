angular.module('loomioApp').controller 'InvitationsModalController', ($scope, $modalInstance, group, InvitablesClient, InvitationsClient, Records) ->
  $scope.group = group
  $scope.fragment = ''
  $scope.invitations = []

  invitablesClient = new InvitablesClient()
  invitationsClient = new InvitationsClient()

  $scope.hasInvitations = ->
    $scope.invitations.length > 0

  $scope.getInvitables = (fragment) ->
    invitablesClient.getByNameFragment(fragment, $scope.group.id).then $scope.handleInvitables

  $scope.handleInvitables = (response) ->
    if angular.element('#invitable-email').hasClass('ng-valid-email')
      response.data.invitables.push { name: "<#{$scope.fragment}>", type: 'Email', email: $scope.fragment }
    response.data.invitables

  $scope.addInvitation = (invitation) ->
    $scope.fragment = ''
    $scope.invitations.push invitation

  $scope.submit = ->
    $scope.isDisabled = true
    invitationsClient.create(invitationsParams()).then($scope.saveSuccess, $scope.saveError)

  invitationsParams = ->
    invitations: $scope.invitations
    group_id: $scope.group.id
    message: $scope.message

  $scope.cancel = ($event) ->
    $event.preventDefault()
    $modalInstance.dismiss('cancel')

  $scope.saveSuccess = () ->
    $scope.isDisabled = false
    $scope.invitations = []
    $modalInstance.close()
    # Repopulate newly added members for group
    Records.memberships.fetchByGroup $scope.group

  $scope.saveError = (error) ->
    $scope.isDisabled = false
    $scope.errorMessages = error.error_messages

