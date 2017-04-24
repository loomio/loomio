angular.module('loomioApp').directive 'pollCountVoteForm', (AppConfig, Records, PollService, TranslationService, MentionService, KeyEventService) ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/count/vote_form/poll_count_vote_form.html'
  controller: ($scope) ->
    $scope.submit = PollService.submitStance $scope, $scope.stance,
      prepareFn: (option) ->
        pollOptionId = if option.name then option.id else $scope.yes.id
        $scope.stance.stanceChoicesAttributes = [poll_option_id: pollOptionId]

    $scope.yes = PollService.optionByName($scope.stance.poll(), 'yes')
    $scope.no  = PollService.optionByName($scope.stance.poll(), 'no')

    TranslationService.eagerTranslate $scope,
      reasonPlaceholder: 'poll_count_vote_form.reason_placeholder'

    MentionService.applyMentions($scope, $scope.stance)
    KeyEventService.submitOnEnter($scope)
