angular.module('loomioApp').directive 'pollProposalForm', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/proposal/form/poll_proposal_form.html'
  controller: ($scope, FormService, KeyEventService, MentionService, TranslationService) ->
    actionName = if $scope.poll.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.poll,
      successCallback: -> $scope.$emit 'pollSaved'
      flashSuccess: "poll_proposal_form.proposal_#{actionName}"
      draftFields: ['title', 'details']

    TranslationService.eagerTranslate $scope,
      titlePlaceholder:   'poll_proposal_form.title_placeholder'
      detailsPlaceholder: 'poll_proposal_form.details_placeholder'

    MentionService.applyMentions($scope, $scope.poll)
    KeyEventService.submitOnEnter($scope)
