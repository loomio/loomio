angular.module('loomioApp').controller 'DiscussionDescriptionEditedItemController', ($scope) ->
  $scope.discussion = $scope.event.discussion()
