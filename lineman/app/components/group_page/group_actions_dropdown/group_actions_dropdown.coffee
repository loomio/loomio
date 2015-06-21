angular.module('loomioApp').directive 'groupActionsDropdown', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_actions_dropdown/group_actions_dropdown.html'
  replace: true
  controllerAs: 'groupActions'
  controller: ($scope, AbilityService, ModalService, EditGroupForm, LeaveGroupForm, ArchiveGroupForm) ->

    @canEditGroup = =>
      AbilityService.canEditGroup($scope.group)

    @canArchiveGroup = =>
      AbilityService.canArchiveGroup($scope.group)

    @editGroup = ->
      ModalService.open EditGroupForm, group: -> $scope.group

    @leaveGroup = ->
      ModalService.open LeaveGroupForm, group: -> $scope.group

    @archiveGroup = ->
      ModalService.open ArchiveGroupForm, group: -> $scope.group

    return
