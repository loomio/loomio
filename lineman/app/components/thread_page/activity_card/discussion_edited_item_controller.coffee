angular.module('loomioApp').controller 'DiscussionEditedItemController', ($scope) ->
  $scope.discussion = $scope.event.discussion()
  $scope.recordEdit = $scope.event.recordEdit()

  $scope.titleEdited =
    $scope.recordEdit.attributeEdited('title')

  $scope.translationKey =
    $scope.recordEdit.editedAttributeNames().join('_')