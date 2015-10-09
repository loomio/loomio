angular.module('loomioApp').factory 'MoveThreadForm', ->
  templateUrl: 'generated/components/move_thread_form/move_thread_form.html'
  controller: ($scope, $location, discussion, CurrentUser, FormService) ->
    $scope.discussion = discussion.clone()

    $scope.availableGroups = ->
      _.filter CurrentUser.groups(), (group) ->
        group.id != discussion.groupId

    $scope.submit = FormService.submit $scope, $scope.discussion,
      submitFn: $scope.discussion.move
      flashSuccess: 'move_thread_form.messages.success'
      flashOptions:
        name: -> $scope.discussion.group().name
