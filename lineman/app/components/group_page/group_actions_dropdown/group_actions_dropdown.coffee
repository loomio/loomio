angular.module('loomioApp').directive 'groupActionsDropdown', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_actions_dropdown/group_actions_dropdown.html'
  replace: true
  controllerAs: 'groupActions'
  controller: ($scope, AbilityService, ModalService, EditGroupForm, StartGroupForm, LeaveGroupForm, ArchiveGroupForm, Records) ->

    @canAdministerGroup = ->
      AbilityService.canAdministerGroup($scope.group)

    @canEditGroup = =>
      AbilityService.canEditGroup($scope.group)

    @canAddSubgroup = ->
      AbilityService.canCreateSubgroups($scope.group)

    @canArchiveGroup = =>
      AbilityService.canArchiveGroup($scope.group)

    @editGroup = ->
      ModalService.open EditGroupForm, group: -> $scope.group

    @addSubgroup = ->
      ModalService.open StartGroupForm, group: -> Records.groups.build(parentId: $scope.group.id)

    @leaveGroup = ->
      ModalService.open LeaveGroupForm, group: -> $scope.group

    @archiveGroup = ->
      ModalService.open ArchiveGroupForm, group: -> $scope.group

    return
