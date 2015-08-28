angular.module('loomioApp').controller 'MotionEditedItemController', ($scope) ->
  version = $scope.event.version()
  proposal = version.proposal()

  $scope.closingAt =
    if version.attributeEdited('closing_at')
      moment(version.changes.closing_at[1]).format("ha dddd, Do MMMM YYYY");
    else
      null

  $scope.title =
    if version.attributeEdited('name')
      version.changes.name[1]
    else
      proposal.name

  $scope.translationKey =
    version.editedAttributeNames().join('_')
