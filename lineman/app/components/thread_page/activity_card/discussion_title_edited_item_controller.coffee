angular.module('loomioApp').controller 'DiscussionTitleEditedItemController', ($scope) ->
  $scope.discussion = $scope.event.discussion()
