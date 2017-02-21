angular.module('loomioApp').directive 'pollProposalForm', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/proposal/form/poll_proposal_form.html'
  controller: ($scope, poll, FormService, AttachmentService, KeyEventService, MentionService, TranslationService) ->
    actionName = if $scope.poll.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.poll,
      successCallback: (data) -> $scope.$emit 'pollSaved', data.polls[0].key
      prepareFn: ->
        $scope.poll.pollOptionNames = _.pluck PollService.fieldFromTemplate('proposal', 'poll_options_attributes'), 'name'
      flashSuccess: "poll_proposal_form.proposal_#{actionName}"
      successCallback: AttachmentService.cleanupAfterUpdate('poll')
      draftFields: ['title', 'details']

    TranslationService.eagerTranslate $scope,
      titlePlaceholder:   'poll_proposal_form.title_placeholder'
      detailsPlaceholder: 'poll_proposal_form.details_placeholder'

    MentionService.applyMentions($scope, $scope.poll)
    KeyEventService.submitOnEnter($scope)
