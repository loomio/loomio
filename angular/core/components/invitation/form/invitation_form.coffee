angular.module('loomioApp').directive 'invitationForm', ->
  scope: {invitationForm: '=', selectGroup: '='}
  restrict: 'E'
  templateUrl: 'generated/components/invitation/form/invitation_form.html'
  controller: ($scope, Records, Session, AbilityService, FlashService, ModalService, AddMembersModal) ->
    $scope.availableGroups = ->
      _.filter Session.user().groups(), (g) ->
        AbilityService.canAddMembers(g)

    $scope.fetchShareableInvitation = ->
      Records.invitations.fetchShareableInvitationByGroupId($scope.invitationForm.groupId)
    $scope.fetchShareableInvitation()

    $scope.addMembers = ->
      ModalService.open AddMembersModal, group: -> $scope.group

    $scope.maxInvitations = ->
      $scope.invitationForm.invitees().length > 100

    $scope.invalidEmail = ->
      $scope.invitationForm.hasEmails() and !$scope.invitationForm.hasInvitees()

    $scope.copied = ->
      FlashService.success('common.copied')

    $scope.invitationLink = ->
      return unless group = Records.groups.find($scope.invitationForm.groupId)
      return unless group.shareableInvitation()
      group.shareableInvitation().url

    return
