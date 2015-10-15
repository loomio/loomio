angular.module('loomioApp').directive 'groupActionsDropdown', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_actions_dropdown/group_actions_dropdown.html'
  replace: true
  controllerAs: 'groupActions'
  controller: ($scope, $window, AppConfig, AbilityService, CurrentUser, ChangeVolumeForm, ModalService, EditGroupForm, StartGroupForm, LeaveGroupForm, ArchiveGroupForm, Records, ChoosePlanModal) ->
    console.log "yeah"

    @canAdministerGroup = ->
      AbilityService.canAdministerGroup($scope.group)

    @canEditGroup = =>
      AbilityService.canEditGroup($scope.group)

    @canManageGroupSubscription = ->
      $scope.group.subscriptionKind != 'trial' and @canAdministerGroup()

    @canAddSubgroup = ->
      AbilityService.canCreateSubgroups($scope.group)

    @canArchiveGroup = =>
      AbilityService.canArchiveGroup($scope.group)

    @canChangeVolume = ->
      CurrentUser.isMemberOf($scope.group)

    @openChangeVolumeForm = ->
      membership = $scope.group.membershipFor(CurrentUser)
      ModalService.open ChangeVolumeForm, model: -> membership

    @editGroup = ->
      ModalService.open EditGroupForm, group: -> $scope.group

    @addSubgroup = ->
      ModalService.open StartGroupForm, group: -> Records.groups.build(parentId: $scope.group.id)

    @leaveGroup = ->
      ModalService.open LeaveGroupForm, group: -> $scope.group

    @archiveGroup = ->
      ModalService.open ArchiveGroupForm, group: -> $scope.group

    @manageSubscriptions = ->
      $window.open "https://www.billingportal.com/s/#{AppConfig.chargify.appName}/login/magic", '_blank'
      true

    @choosePlan = ->
      ModalService.open ChoosePlanModal, group: -> $scope.group

    return
