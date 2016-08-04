angular.module('loomioApp').factory 'DiscussionForm', ->
  templateUrl: 'generated/components/discussion_form/discussion_form.html'
  controller: ($scope, $controller, $location, discussion, Session, Records, AbilityService, FormService, MentionService, AttachmentService, KeyEventService, PrivacyString, EmojiService) ->
    $scope.discussion = discussion.clone()

    if $scope.discussion.isNew()
      $scope.showGroupSelect = true

    actionName = if $scope.discussion.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.discussion,
      flashSuccess: "discussion_form.messages.#{actionName}"
      draftFields: ['title', 'description']
      successCallback: (response) =>
        discussion = response.discussions[0]
        Records.attachments.find(attachableId: discussion.id, attachableType: 'Discussion')
                           .filter (attachment) -> !_.contains(discussion.attachment_ids, attachment.id)
                           .map    (attachment) -> attachment.remove()
        $location.path "/d/#{discussion.key}" if actionName == 'created'

    $scope.availableGroups = ->
      _.filter Session.user().groups(), (group) ->
        AbilityService.canStartThread(group)

    # NB; this overrides the restoreDraft() function applied in draft_service
    $scope.restoreDraft = ->
      return unless $scope.discussion.group()? and $scope.discussion.isNew()
      $scope.discussion.restoreDraft()
      $scope.updatePrivacy()

    $scope.privacyPrivateDescription = ->
      PrivacyString.discussion($scope.discussion, true)

    $scope.updatePrivacy = ->
      $scope.discussion.private = $scope.discussion.privateDefaultValue()

    $scope.showPrivacyForm = ->
      return unless $scope.discussion.group()
      $scope.discussion.group().discussionPrivacyOptions == 'public_or_private'

    $scope.descriptionSelector = '.discussion-form__description-input'
    EmojiService.listen $scope, $scope.discussion, 'description', $scope.descriptionSelector

    AttachmentService.listenForPaste $scope
    KeyEventService.submitOnEnter $scope
    MentionService.applyMentions $scope, $scope.discussion

    $scope.$on 'disableAttachmentForm', -> $scope.submitIsDisabled = true
    $scope.$on 'enableAttachmentForm',  -> $scope.submitIsDisabled = false
    $scope.$on 'attachmentRemoved', (event, attachment) ->
      ids = $scope.discussion.newAttachmentIds
      ids.splice ids.indexOf(attachment.id), 1
      attachment.destroy() unless _.contains $scope.discussion.attachmentIds, attachment.id
