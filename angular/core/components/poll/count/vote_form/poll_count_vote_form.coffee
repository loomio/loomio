angular.module('loomioApp').directive 'pollCountVoteForm', (AppConfig, Records, PollService, TranslationService, MentionService, KeyEventService) ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/count/vote_form/poll_count_vote_form.html'
  controller: ($scope) ->
    $scope.submit = PollService.submitStance $scope, $scope.stance,
      prepareFn: (option) ->
        $scope.stance.stanceChoicesAttributes = [poll_option_id: option.id]

    TranslationService.eagerTranslate $scope,
      reasonPlaceholder: 'poll_count_vote_form.reason_placeholder'

    MentionService.applyMentions($scope, $scope.stance)
    KeyEventService.submitOnEnter($scope)
