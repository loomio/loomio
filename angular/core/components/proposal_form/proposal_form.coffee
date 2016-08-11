angular.module('loomioApp').factory 'ProposalForm', ->
  templateUrl: 'generated/components/proposal_form/proposal_form.html'
  controller: ($scope, $rootScope, proposal, FormService, MentionService, KeyEventService, ScrollService, EmojiService, UserHelpService, Records) ->
    $scope.nineWaysArticleLink = ->
      UserHelpService.nineWaysArticleLink()

    $scope.proposal = proposal.clone()

    actionName = if $scope.proposal.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.proposal,
      flashSuccess: "proposal_form.messages.#{actionName}"
      draftFields: ['name', 'description']
      successEvent: 'proposalCreated'
      successCallback: ->
        $rootScope.$broadcast 'setSelectedProposal'
        Records.attachments.find(attachableId: proposal.id, attachableType: 'Proposal')
                           .filter (attachment) -> !_.contains(proposal.attachment_ids, attachment.id)
                           .map    (attachment) -> attachment.remove()
        ScrollService.scrollTo('#current-proposal-card-heading')

    $scope.descriptionSelector = '.proposal-form__details-field'

    EmojiService.listen $scope, $scope.proposal, 'description', $scope.descriptionSelector

    KeyEventService.submitOnEnter $scope
    MentionService.applyMentions $scope, $scope.proposal

    $scope.$on 'disableAttachmentForm', -> $scope.submitIsDisabled = true
    $scope.$on 'enableAttachmentForm',  -> $scope.submitIsDisabled = false
    $scope.$on 'attachmentRemoved', (event, attachment) ->
      ids = $scope.proposal.newAttachmentIds
      ids.splice ids.indexOf(attachment.id), 1
      attachment.destroy() unless _.contains $scope.proposal.attachmentIds, attachment.id
