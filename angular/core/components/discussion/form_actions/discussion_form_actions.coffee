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
        discussion = response.discussions[0]
        $scope.$emit 'nextStep', discussion
        AttachmentService.cleanupAfterUpdate(discussion, 'discussion')
        $location.path LmoUrlService.discussion(discussion) if actionName == 'created'

    KeyEventService.submitOnEnter $scope
