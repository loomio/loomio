angular.module('loomioApp').directive 'pollDotVoteForm', ->
  scope: {poll: '=', back: '=?'}
  templateUrl: 'generated/components/poll/dot_vote/form/poll_dot_vote_form.html'
  controller: ($scope, PollService, AttachmentService, KeyEventService, TranslationService) ->
    TranslationService.eagerTranslate $scope,
      titlePlaceholder:     'poll_dot_vote_form.title_placeholder'
      detailsPlaceholder:   'poll_dot_vote_form.details_placeholder'
      addOptionPlaceholder: 'poll_dot_vote_form.add_option_placeholder'

    $scope.poll.customFields.dots_per_person = $scope.poll.customFields.dots_per_person or 8

    $scope.submit = PollService.submitPoll $scope, $scope.poll,
      prepareFn: ->
        $scope.$emit 'processing'
        $scope.$broadcast('addPollOption')

    KeyEventService.submitOnEnter($scope)
