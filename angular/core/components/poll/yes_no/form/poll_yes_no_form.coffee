angular.module('loomioApp').factory 'PollYesNoForm', ->
  templateUrl: 'generated/components/poll/yes_no/form/poll_yes_no_form.html'
  controller: ($scope, poll, FormService, AttachmentService, KeyEventService, TranslationService) ->
    $scope.poll = poll.clone()
    $scope.poll.makeAnnouncement = $scope.poll.isNew()

    actionName = if $scope.poll.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.poll,
      prepareFn: ->
        $scope.poll.pollOptionNames = [
          $scope.poll.affirmativeText, $scope.poll.negativeText
        ] if $scope.poll.isNew()
      successCallback: AttachmentService.cleanupAfterUpdate('poll')
      flashSuccess: "poll_yes_no_form.yes_no_#{actionName}"
      draftFields: ['title', 'details', 'action']

    TranslationService.eagerTranslate $scope,
      titlePlaceholder:   'poll_yes_no_form.title_placeholder'
      detailsPlaceholder: 'poll_yes_no_form.details_placeholder'
      actionPlaceholder:  'poll_yes_no_form.action_placeholder'
      affirmativePlaceholder:  'poll_yes_no_form.affirmative_placeholder'
      negativePlaceholder:  'poll_yes_no_form.negative_placeholder'

    KeyEventService.submitOnEnter($scope)
