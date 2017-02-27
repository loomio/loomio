angular.module('loomioApp').directive 'pollCountVoteForm', (AppConfig, Records, FormService, TranslationService, MentionService, KeyEventService) ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/count/vote_form/poll_count_vote_form.html'
  controller: ($scope) ->
    $scope.stance.stanceChoicesAttributes = [{poll_option_id: $scope.stance.poll().firstOption().id}]

    actionName = if $scope.stance.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.stance,
      prepareFn: (option) ->
        $scope.stance.stanceChoicesAttributes = [poll_option_id: option.id]
      successCallback: -> $scope.$emit 'stanceSaved'
      flashSuccess: "poll_count_vote_form.stance_#{actionName}"
      draftFields: ['reason']

    TranslationService.eagerTranslate $scope,
      reasonPlaceholder: 'poll_count_vote_form.reason_placeholder'

    MentionService.applyMentions($scope, $scope.stance)
    KeyEventService.submitOnEnter($scope)
