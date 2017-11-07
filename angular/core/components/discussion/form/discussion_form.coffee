angular.module('loomioApp').directive 'discussionForm', ->
  scope: {discussion: '='}
  templateUrl: 'generated/components/discussion/form/discussion_form.html'
  controller: ($scope, $controller, $location, Session, Records, AbilityService, FormService, MentionService, AttachmentService, KeyEventService, PrivacyString) ->
    if $scope.discussion.isNew()
      $scope.discussion.makeAnnouncement = true
      $scope.showGroupSelect = true

    actionName = if $scope.discussion.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.discussion,
      flashSuccess: "discussion_form.messages.#{actionName}"
      drafts: true
      successCallback: (response) =>
        $scope.$emit 'discussionSaved'
        discussion = response.discussions[0]
        Records.attachments.find(attachableId: discussion.id, attachableType: 'Discussion')
                           .filter (attachment) -> !_.contains(discussion.attachment_ids, attachment.id)
                           .map    (attachment) -> attachment.remove()
        $location.path "/d/#{discussion.key}" if actionName == 'created'

    $scope.availableGroups = ->
      _.filter Session.user().formalGroups(), (group) ->
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
      return true unless $scope.discussion.group()
      $scope.discussion.group().discussionPrivacyOptions == 'public_or_private'

    AttachmentService.listenForAttachments $scope, $scope.discussion
    KeyEventService.submitOnEnter $scope
