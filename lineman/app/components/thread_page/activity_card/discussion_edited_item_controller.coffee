angular.module('loomioApp').controller 'DiscussionEditedItemController', ($scope) ->
  $scope.discussion = $scope.event.discussion()
  $scope.version = $scope.event.version()

  $scope.titleEdited =
    $scope.version.attributeEdited('title')

  $scope.translationKey =
    $scope.version.editedAttributeNames().join('_')
