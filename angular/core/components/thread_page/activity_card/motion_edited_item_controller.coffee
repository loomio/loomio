angular.module('loomioApp').controller 'MotionEditedItemController', ($scope, Records) ->
  version = Records.versions.find($scope.event.eventable.id)

  $scope.closingAt =
    if version.attributeEdited('closing_at')
      moment(version.changes.closing_at[1]).format("ha dddd, Do MMMM YYYY");

  $scope.title =
    if version.attributeEdited('name')
      version.changes.name[1]
    else
      version.proposal().name

  $scope.translationKey =
    version.editedAttributeNames().join('_')
