angular.module('loomioApp').directive 'pollProposalVoteForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/proposal/vote_form/poll_proposal_vote_form.html'
  controller: ($scope, FormService, TranslationService, MentionService, KeyEventService) ->
    actionName = if $scope.stance.isNew() then 'created' else 'updated'
    $scope.stance.selectedOption = $scope.stance.pollOption()

    $scope.submit = FormService.submit $scope, $scope.stance,
      prepareFn: ->
        $scope.stance.stanceChoicesAttributes = [{ poll_option_id: $scope.stance.selectedOption.id }]
      successCallback: -> $scope.$emit 'stanceSaved'
      flashSuccess: "poll_proposal_vote_form.stance_#{actionName}"
      draftFields: ['reason']

    $scope.cancelOption = -> $scope.stance.selected = null

    $scope.reasonPlaceholder = ->
      pollOptionName = ($scope.stance.selectedOption or {}).name
      $scope.translations["#{pollOptionName or 'default'}Placeholder"]

    TranslationService.eagerTranslate $scope,
      defaultPlaceholder:  'poll_proposal_vote_form.default_reason_placeholder'
      agreePlaceholder:    'poll_proposal_vote_form.agree_reason_placeholder'
      abstainPlaceholder:  'poll_proposal_vote_form.abstain_reason_placeholder'
      disagreePlaceholder: 'poll_proposal_vote_form.disagree_reason_placeholder'
      blockPlaceholder:    'poll_proposal_vote_form.block_reason_placeholder'

    MentionService.applyMentions($scope, $scope.stance)
    KeyEventService.submitOnEnter($scope)
