angular.module('loomioApp').controller 'MotionEditedItemController', ($scope) ->
  $scope.proposal = $scope.event.recordEdit().proposal()
  recordEdit = $scope.event.recordEdit()
  $scope.proposalName =
    if _.include(_.keys(recordEdit.newValues), 'name')
      recordEdit.newValues.name
    else
      $scope.proposal.name

  $scope.translationKey =
    recordEdit.editedAttributeNames().join('_')