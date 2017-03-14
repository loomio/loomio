angular.module('loomioApp').directive 'pollProposalForm', ->
  scope: {poll: '=', back: '=?'}
  templateUrl: 'generated/components/poll/proposal/form/poll_proposal_form.html'
  controller: ($scope, PollService, AttachmentService, KeyEventService, MentionService, TranslationService) ->
    $scope.submit = PollService.submitPoll $scope, $scope.poll,
      prepareFn: ->
        $scope.poll.pollOptionNames = _.pluck PollService.fieldFromTemplate('proposal', 'poll_options_attributes'), 'name'

    TranslationService.eagerTranslate $scope,
      titlePlaceholder:   'poll_proposal_form.title_placeholder'
      detailsPlaceholder: 'poll_proposal_form.details_placeholder'

    MentionService.applyMentions($scope, $scope.poll)
    KeyEventService.submitOnEnter($scope)
