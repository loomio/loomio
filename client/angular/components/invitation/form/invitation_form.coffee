Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'

angular.module('loomioApp').directive 'invitationForm', (FlashService, ModalService, AddMembersModal) ->
  scope: {invitationForm: '='}
  restrict: 'E'
  templateUrl: 'generated/components/invitation/form/invitation_form.html'
  controller: ($scope) ->
    $scope.selectGroup = _.isNumber $scope.invitationForm.groupId

    $scope.availableGroups = ->
      _.filter Session.user().groups(), (g) ->
        AbilityService.canAddMembers(g)

    $scope.fetchShareableInvitation = ->
      Records.invitations.fetchShareableInvitationByGroupId($scope.invitationForm.groupId)
    $scope.fetchShareableInvitation()

    $scope.addMembers = ->
      ModalService.open AddMembersModal, group: -> $scope.group()

    $scope.maxInvitations = ->
      $scope.invitationForm.invitees().length > 100

    $scope.invalidEmail = ->
      $scope.invitationForm.hasEmails() and !$scope.invitationForm.hasInvitees()

    $scope.group = ->
      Records.groups.find $scope.invitationForm.groupId

    $scope.copied = ->
      FlashService.success('common.copied')

    $scope.invitationLink = ->
      return unless $scope.group() and $scope.group().shareableInvitation()
      $scope.group().shareableInvitation().url

    return
