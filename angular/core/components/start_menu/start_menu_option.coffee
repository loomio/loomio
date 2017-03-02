angular.module('loomioApp').directive 'startMenuOption', ->
  scope: {text: '@', icon: '@', action: '@', group: '=?', hotkey: '@?'}
  restrict: 'E'
  templateUrl: 'generated/components/start_menu/start_menu_option.html'
  replace: true,
  controller: ($scope, ModalService, InvitationForm, DiscussionForm, GroupForm, PollCommonStartModal, Records, AbilityService, KeyEventService, Session) ->

    $scope.openModal = ->
      switch $scope.action
        when 'invitePeople'
          ModalService.open InvitationForm, group: -> $scope.currentGroup()
        when 'startGroup'
          ModalService.open GroupForm, group: -> Records.groups.build()
        when 'startThread'
          ModalService.open DiscussionForm, discussion: -> Records.discussions.build(groupId: $scope.currentGroup().id)
        when 'startPoll'
          ModalService.open PollCommonStartModal, poll: -> Records.polls.build()
    if $scope.hotkey
      KeyEventService.registerKeyEvent $scope, $scope.hotkey, $scope.openModal

    availableGroups = ->
      _.filter Session.user().groups(), (group) ->
        AbilityService.canAddMembers(group)

    $scope.currentGroup = ->
      return _.first(availableGroups()) if availableGroups().length == 1
      _.find(availableGroups(), (g) -> g.id == Session.currentGroupId()) || Records.groups.build()
