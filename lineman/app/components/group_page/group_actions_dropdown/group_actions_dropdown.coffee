angular.module('loomioApp').directive 'groupActionsDropdown', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_actions_dropdown/group_actions_dropdown.html'
  replace: true
  controllerAs: 'groupActions'
  controller: ($scope, $window, AppConfig, AbilityService, ModalService, EditGroupForm, LeaveGroupForm, ArchiveGroupForm, ChoosePlanModal) ->

    @canAdministerGroup = ->
      AbilityService.canAdministerGroup($scope.group)

    @canEditGroup = =>
      AbilityService.canEditGroup($scope.group)

    @canManageGroupSubscription = ->
      $scope.group.subscriptionKind != 'trial' and @canAdministerGroup()

    @canArchiveGroup = =>
      AbilityService.canArchiveGroup($scope.group)

    @editGroup = ->
      ModalService.open EditGroupForm, group: -> $scope.group

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
