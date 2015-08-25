angular.module('loomioApp').controller 'MotionEditedItemController', ($scope) ->
  $scope.proposal = $scope.event.version().proposal()
  version = $scope.event.version()
  $scope.proposalName =
    if version.attributeEdited('name')
      version.changes.name[1]
    else
      $scope.proposal.name

  $scope.translationKey =
    version.editedAttributeNames().join('_')
