angular.module('loomioApp').directive 'pollDotVoteForm', ->
  scope: {poll: '=', back: '=?'}
  templateUrl: 'generated/components/poll/dot_vote/form/poll_dot_vote_form.html'
  controller: ($scope, PollService, AttachmentService, KeyEventService, TranslationService) ->
    TranslationService.eagerTranslate $scope,
      titlePlaceholder:     'poll_dot_vote_form.title_placeholder'
      detailsPlaceholder:   'poll_dot_vote_form.details_placeholder'
      addOptionPlaceholder: 'poll_dot_vote_form.add_option_placeholder'

    $scope.addOption = ->
      return unless $scope.newOptionName
      $scope.poll.pollOptionNames.push $scope.newOptionName
      $scope.newOptionName = ''

    $scope.removeOption = (name) ->
      _.pull $scope.poll.pollOptionNames, name

    $scope.submit = PollService.submitPoll $scope, $scope.poll,
      prepareFn: $scope.addOption

    KeyEventService.submitOnEnter($scope)
    KeyEventService.registerKeyEvent $scope, 'pressedEnter', $scope.addOption, (active) ->
      active.classList.contains('poll-dot-vote-form__add-option-input')
