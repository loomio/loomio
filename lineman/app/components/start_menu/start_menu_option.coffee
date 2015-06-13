angular.module('loomioApp').directive 'startMenuOption', ->
  scope: {text: '@', icon: '@', action: '@', group: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/start_menu/start_menu_option.html'
  replace: true,
  controller: ($scope, ModalService, InvitationForm, DiscussionForm, StartGroupForm, Records) ->
    $scope.openModal = ->
      switch $scope.action
        when 'invitePeople' then ModalService.open InvitationForm, 
          group:      -> $scope.group or Records.groups.initialize()
        when 'startGroup' then ModalService.open StartGroupForm,
          group:      -> Records.groups.initialize()
        when 'startSubgroup' then ModalService.open StartGroupForm,
          group:      -> Records.groups.initialize(parent_id: $scope.currentGroupId())
        when 'startThread' then ModalService.open DiscussionForm,
          discussion: -> Records.discussions.initialize(group_id: $scope.currentGroupId())

    $scope.currentGroupId = ->
      $scope.group.id if $scope.group?