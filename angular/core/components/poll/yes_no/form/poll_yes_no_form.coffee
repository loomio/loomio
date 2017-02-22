angular.module('loomioApp').directive 'pollYesNoForm', ->
  scope: {poll: '=', back: '=?'}
  templateUrl: 'generated/components/poll/yes_no/form/poll_yes_no_form.html'
  controller: ($scope, PollService, AttachmentService, KeyEventService, TranslationService) ->
    $scope.submit = PollService.submitPoll $scope, $scope.poll,
      prepareFn: ->
        $scope.poll.pollOptionNames = [
          $scope.poll.affirmativeText, $scope.poll.negativeText
        ] if $scope.poll.isNew()

    TranslationService.eagerTranslate $scope,
      titlePlaceholder:   'poll_yes_no_form.title_placeholder'
      detailsPlaceholder: 'poll_yes_no_form.details_placeholder'
      actionPlaceholder:  'poll_yes_no_form.action_placeholder'
      affirmativePlaceholder:  'poll_yes_no_form.affirmative_placeholder'
      negativePlaceholder:  'poll_yes_no_form.negative_placeholder'

    KeyEventService.submitOnEnter($scope)
