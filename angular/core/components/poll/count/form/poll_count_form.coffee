angular.module('loomioApp').directive 'pollCountForm', ->
  scope: {poll: '=', back: '=?'}
  templateUrl: 'generated/components/poll/count/form/poll_count_form.html'
  controller: ($scope, FormService, AttachmentService, PollService, KeyEventService, TranslationService) ->
    $scope.submit = PollService.submitPoll $scope, $scope.poll,
      prepareFn: ->
        $scope.poll.pollOptionNames = _.pluck PollService.fieldFromTemplate('count', 'poll_options_attributes'), 'name'

    TranslationService.eagerTranslate $scope,
      titlePlaceholder:   'poll_count_form.title_placeholder'
      detailsPlaceholder: 'poll_count_form.details_placeholder'
      actionPlaceholder:  'poll_count_form.action_placeholder'
      affirmativePlaceholder:  'poll_count_form.affirmative_placeholder'
      negativePlaceholder:  'poll_count_form.negative_placeholder'

    KeyEventService.submitOnEnter($scope)
