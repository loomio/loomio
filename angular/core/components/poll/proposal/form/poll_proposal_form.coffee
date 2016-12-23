angular.module('loomioApp').factory 'PollProposalForm', ->
  templateUrl: 'generated/components/poll/proposal/form/poll_proposal_form.html'
  controller: ($scope, $translate, poll, FormService) ->
    $scope.poll = poll.clone()

    actionName = if $scope.poll.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.poll,
      flashSuccess: "poll_proposal_form.messages.#{actionName}"
      draftFields: ['title', 'details']

    $scope.translations =
      titlePlaceholder:   $translate.instant 'poll_proposal_form.title_placeholder'
      detailsPlaceholder: $translate.instant 'poll_proposal_form.details_placeholder'
