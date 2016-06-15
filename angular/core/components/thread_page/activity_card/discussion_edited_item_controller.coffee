angular.module('loomioApp').controller 'DiscussionEditedItemController', ($scope, Records) ->
  version    = Records.versions.find($scope.event.eventable.id)
  discussion = Records.discussions.find(version.discussionId)

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

  $scope.translationKey =
    if _.isEqual version.editedAttributeNames(), ['attachment_ids']
      'attachment_ids'
    else
      _.without(version.editedAttributeNames(), 'attachment_ids').join('_')
