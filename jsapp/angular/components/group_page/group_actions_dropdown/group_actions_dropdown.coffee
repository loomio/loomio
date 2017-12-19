angular.module('loomioApp').directive 'groupActionsDropdown', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_actions_dropdown/group_actions_dropdown.html'
  replace: true
  controller: ($scope, $window, AppConfig, AbilityService, Session, ChangeVolumeForm, ModalService, GroupModal, LeaveGroupForm, ArchiveGroupForm, Records) ->

    $scope.canAdministerGroup = ->
      AbilityService.canAdministerGroup($scope.group)

    $scope.canEditGroup = =>
      AbilityService.canEditGroup($scope.group)

    $scope.canAddSubgroup = ->
      AbilityService.canCreateSubgroups($scope.group)

    $scope.canArchiveGroup = =>
      AbilityService.canArchiveGroup($scope.group)

    $scope.canLeaveGroup = =>
      AbilityService.canLeaveGroup($scope.group)

    $scope.canChangeVolume = ->
      AbilityService.canChangeGroupVolume($scope.group)

    $scope.openChangeVolumeForm = ->
      ModalService.open ChangeVolumeForm, model: -> $scope.group.membershipFor(Session.user())

    $scope.editGroup = ->
      ModalService.open GroupModal, group: -> $scope.group

    $scope.addSubgroup = ->
      ModalService.open GroupModal, group: -> Records.groups.build(parentId: $scope.group.id)

    $scope.leaveGroup = ->
      ModalService.open LeaveGroupForm, group: -> $scope.group

    $scope.archiveGroup = ->
      ModalService.open ArchiveGroupForm, group: -> $scope.group

    return
