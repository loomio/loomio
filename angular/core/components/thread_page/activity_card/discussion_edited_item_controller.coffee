angular.module('loomioApp').controller 'DiscussionEditedItemController', ($scope) ->
  discussion = $scope.event.discussion()
  version = $scope.event.version()

  $scope.title =
    if version.attributeEdited('title')
      version.changes.title[1]
    else
      ''

  $scope.actorName = $scope.event.actorName()

  $scope.translationKey =
    version.editedAttributeNames().join('_')
