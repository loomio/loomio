angular.module('loomioApp').controller 'DiscussionFormController', ($scope, DiscussionModel, DiscussionService, discussion) ->
  $scope.discussion = discussion

  saveSuccess = ->
    console.log 'saved the discussion'

  saveError = (error) ->
    console.log error

  $scope.submit = ->
    DiscussionService.save($scope.discussion, saveSuccess, saveError)


