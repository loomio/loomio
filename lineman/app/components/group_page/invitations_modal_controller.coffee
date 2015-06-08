angular.module('loomioApp').controller 'InvitationsModalController', ($scope, $modalInstance, group, InvitablesClient, InvitationsClient, Records, CurrentUser) ->
  $scope.group = group
  $scope.fragment = ''
  $scope.invitations = []

  invitablesClient = new InvitablesClient()
  invitationsClient = new InvitationsClient()

  $scope.hasInvitations = ->
    $scope.invitations.length > 0

  $scope.invitables = ->
    invitables = []
    invitables.push $scope.invitableEmail() if $scope.fragmentIsValidEmail()
    invitables.push $scope.invitableGroups()
    invitables.push $scope.invitableContacts()
    _.flatten invitables

  $scope.invitableEmail = ->
    name: "<#{$scope.fragment}>"
    type: "Email"
    email: $scope.fragment

  $scope.invitableGroups = ->
    groups = _.filter $scope.availableGroups(), (group) ->
      group.id != $scope.group.id and ~group.name.search(new RegExp($scope.fragment, 'i'))
    _.map groups, (group) ->
      name:     group.name
      subtitle: "Add all members (#{group.membersCount})"
      image:    group.logoUrl()

  $scope.invitableContacts = ->
    memberIds = _.uniq _.flatten _.map $scope.availableGroups(), (group) -> group.memberIds()
    memberIds = _.filter memberIds, (memberId) -> 
      !_.contains $scope.group.memberIds(), memberId
    _.map Records.users.find(memberIds), (user) ->
      name:     user.name
      subtitle: "@#{user.username()}"
      image:    user.avatarUrl

  $scope.getInvitables = (fragment) ->
    invitablesClient.getByNameFragment(fragment, $scope.group.id)
    $scope.invitables()

  $scope.fragmentIsValidEmail = ->
    $scope.invitableForm.fragment.$valid

  $scope.availableGroups = ->
    CurrentUser.groups()

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

  $scope.saveSuccess = ->
    $scope.isDisabled = false
    $scope.invitations = []
    $modalInstance.close()
    # Repopulate newly added members for group
    Records.memberships.fetchByGroup $scope.group

  $scope.saveError = (error) ->
    $scope.isDisabled = false
    $scope.errorMessages = error.error_messages

