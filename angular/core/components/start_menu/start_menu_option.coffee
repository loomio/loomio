angular.module('loomioApp').directive 'startMenuOption', ->
  scope: {text: '@', icon: '@', action: '@', group: '=?', hotkey: '@?'}
  restrict: 'E'
  templateUrl: 'generated/components/start_menu/start_menu_option.html'
  replace: true,
  controller: ($scope, ModalService, InvitationForm, DiscussionForm, GroupForm, Records, AbilityService, KeyEventService, CurrentUser) ->

    $scope.openModal = ->
      switch $scope.action
        when 'invitePeople'
          ModalService.open InvitationForm, group: -> $scope.invitePeopleGroup()
        when 'startGroup'
          ModalService.open GroupForm, group: -> Records.groups.build()
        when 'startThread'
          ModalService.open DiscussionForm, discussion: -> Records.discussions.build(groupId: $scope.currentGroupId())
    if $scope.hotkey
      KeyEventService.registerKeyEvent $scope, $scope.hotkey, $scope.openModal

    availableGroups = ->
      _.filter CurrentUser.groups(), (group) ->
        AbilityService.canAddMembers(group)

    $scope.invitePeopleGroup = ->
      if $scope.group and AbilityService.canAddMembers($scope.group)
        $scope.group
      else if availableGroups().length == 1
        $scope.group = _.first availableGroups()
      else
        Records.groups.build()

    $scope.currentGroupId = ->
      $scope.group.id if $scope.group?
