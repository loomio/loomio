angular.module('loomioApp').directive 'startMenuOption', ->
  scope: {text: '@', icon: '@', action: '@', group: '=?', hotkey: '@?'}
  restrict: 'E'
  templateUrl: 'generated/components/start_menu/start_menu_option.html'
  replace: true,
  controller: ($scope, ModalService, InvitationForm, DiscussionForm, StartGroupForm, Records, AbilityService, KeyEventService) ->

    $scope.openModal = ->
      switch $scope.action
        when 'invitePeople'
          ModalService.open InvitationForm, group: -> $scope.invitePeopleGroup()
        when 'startGroup'
          ModalService.open StartGroupForm, group: -> Records.groups.build()
        when 'startSubgroup'
          ModalService.open StartGroupForm, group: -> Records.groups.build(parentId: $scope.currentGroupId())
        when 'startThread'
          ModalService.open DiscussionForm, discussion: -> Records.discussions.build(groupId: $scope.currentGroupId())
    if $scope.hotkey
      KeyEventService.registerKeyEvent $scope, $scope.hotkey, $scope.openModal

    $scope.invitePeopleGroup = ->
      if $scope.group and AbilityService.canAddMembers($scope.group)
        $scope.group
      else
        Records.groups.build()

    $scope.currentGroupId = ->
      $scope.group.id if $scope.group?
