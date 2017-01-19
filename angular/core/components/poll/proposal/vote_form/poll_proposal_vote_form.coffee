angular.module('loomioApp').directive 'pollProposalVoteForm', ->
  scope: {stance: '=', pollOption: '=?'}
  templateUrl: 'generated/components/poll/proposal/vote_form/poll_proposal_vote_form.html'
  controller: ($scope, FormService, TranslationService, MentionService, KeyEventService) ->
    actionName = if $scope.stance.isNew() then 'created' else 'updated'
    $scope.stance.selectedOption = $scope.pollOption

    $scope.submit = FormService.submit $scope, $scope.stance,
      prepareFn: ->
        $scope.stance.stanceChoicesAttributes = [{ poll_option_id: $scope.stance.selectedOption.id }]
      successCallback: -> $scope.$emit '$close'
      flashSuccess: "poll_proposal_vote_form.stance_#{actionName}"
      draftFields: ['reason']

    $scope.cancelOption = -> $scope.stance.selected = null

    TranslationService.eagerTranslate
      detailsPlaceholder: 'poll_common.statement_placeholder'

    MentionService.applyMentions($scope, $scope.stance)
    KeyEventService.submitOnEnter($scope)
