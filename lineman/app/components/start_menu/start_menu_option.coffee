angular.module('loomioApp').directive 'startMenuOption', ->
  scope: {text: '@', icon: '@', action: '@', group: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/start_menu/start_menu_option.html'
  replace: true,
  controller: ($scope, ModalService, InvitationForm, DiscussionForm, StartGroupForm, Records, CurrentUser) ->
    $scope.openModal = ->
      switch $scope.action
        when 'invitePeople' then ModalService.open InvitationForm, 
          group:      -> $scope.invitePeopleGroup()
        when 'startGroup' then ModalService.open StartGroupForm,
          group:      -> Records.groups.initialize()
        when 'startSubgroup' then ModalService.open StartGroupForm,
          group:      -> Records.groups.initialize(parent_id: $scope.currentGroupId())
        when 'startThread' then ModalService.open DiscussionForm,
          discussion: -> Records.discussions.initialize(group_id: $scope.currentGroupId())

    $scope.invitePeopleGroup = ->
      if $scope.group and CurrentUser.canInviteTo($scope.group)
        $scope.group 
      else 
        Records.groups.initialize()

    $scope.currentGroupId = ->
      $scope.group.id if $scope.group?