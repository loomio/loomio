angular.module('loomioApp').factory 'PollProposalForm', ->
  templateUrl: 'generated/components/poll/proposal/form/poll_proposal_form.html'
  controller: ($scope, poll, FormService, KeyEventService, TranslationService) ->
    $scope.poll = poll.clone()
    $scope.poll.makeAnnouncement = $scope.poll.isNew()

    actionName = if $scope.poll.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.poll,
      flashSuccess: "poll_proposal_form.messages.#{actionName}"
      draftFields: ['title', 'details']

    TranslationService.eagerTranslate $scope,
      titlePlaceholder:   'poll_proposal_form.title_placeholder'
      detailsPlaceholder: 'poll_proposal_form.details_placeholder'

    KeyEventService.submitOnEnter($scope)
