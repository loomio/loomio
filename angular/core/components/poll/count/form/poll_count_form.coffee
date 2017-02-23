angular.module('loomioApp').factory 'PollCountForm', ->
  templateUrl: 'generated/components/poll/count/form/poll_count_form.html'
  controller: ($scope, poll, FormService, AttachmentService, KeyEventService, TranslationService) ->
    $scope.poll = poll.clone()
    $scope.poll.makeAnnouncement = $scope.poll.isNew()

    actionName = if $scope.poll.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.poll,
      successCallback: AttachmentService.cleanupAfterUpdate('poll')
      flashSuccess: "poll_count_form.count_#{actionName}"
      draftFields: ['title', 'details', 'action']

    TranslationService.eagerTranslate $scope,
      titlePlaceholder:   'poll_count_form.title_placeholder'
      detailsPlaceholder: 'poll_count_form.details_placeholder'
      actionPlaceholder:  'poll_count_form.action_placeholder'
      affirmativePlaceholder:  'poll_count_form.affirmative_placeholder'
      negativePlaceholder:  'poll_count_form.negative_placeholder'

    KeyEventService.submitOnEnter($scope)
