angular.module('loomioApp').directive 'startMenuOption', ->
  scope: {text: '@', icon: '@', action: '@', group: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/start_menu/start_menu_option.html'
  replace: true,
  controller: ($scope, ModalService, InvitationForm, DiscussionForm, StartGroupForm, Records, AbilityService) ->
    $scope.openModal = ->
      switch $scope.action
        when 'invitePeople' then ModalService.open InvitationForm,
          group:      -> $scope.invitePeopleGroup()
        when 'startGroup' then ModalService.open StartGroupForm,
          group:      -> Records.groups.build()
        when 'startSubgroup' then ModalService.open StartGroupForm,
          group:      -> Records.groups.build(parent_id: $scope.currentGroupId())
        when 'startThread' then ModalService.open DiscussionForm,
          discussion: -> Records.discussions.build(group_id: $scope.currentGroupId())

    $scope.invitePeopleGroup = ->
      if $scope.group and AbilityService.canAddMembers($scope.group)
        $scope.group
      else
        Records.groups.build()

    $scope.currentGroupId = ->
      $scope.group.id if $scope.group?
