angular.module('loomioApp').directive 'discussionFormActions', ->
  scope: {discussion: '='}
  replace: true
  templateUrl: 'generated/components/discussion/form_actions/discussion_form_actions.html'
  controller: ($scope, $location, Records, FormService, LmoUrlService, KeyEventService, AttachmentService) ->
    actionName = if $scope.discussion.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.discussion,
      flashSuccess: "discussion_form.messages.#{actionName}"
      drafts: true
      successCallback: (response) =>
        $scope.$emit '$close'
        discussion = response.discussions[0]
        Records.attachments.find(attachableId: discussion.id, attachableType: 'Discussion')
                           .filter (attachment) -> !_.contains(discussion.attachment_ids, attachment.id)
                           .map    (attachment) -> attachment.remove()
        $location.path LmoUrlService.discussion(discussion) if actionName == 'created'

    KeyEventService.submitOnEnter $scope
    AttachmentService.listenForAttachments $scope, $scope.discussion
