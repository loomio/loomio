angular.module('loomioApp').controller 'DiscussionEditedItemController', ($scope) ->
  discussion = $scope.event.discussion()
  version = $scope.event.version()

  $scope.title =
    if version.attributeEdited('title')
      version.changes.title[1]
    else
      ''
  $scope.onlyPrivacyEdited = ->
    version.attributeEdited('private') and
    !version.attributeEdited('title') and
    !version.attributeEdited('description')

  $scope.privacyKey = ->
    return unless $scope.onlyPrivacyEdited()
    if version.changes.private[1]
     'discussion_edited_item.public_to_private'
    else
     'discussion_edited_item.private_to_public'

  $scope.actorName = $scope.event.actorName()

  $scope.translationKey =
    version.editedAttributeNames().join('_')
