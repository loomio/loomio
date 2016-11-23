angular.module('loomioApp').factory 'ProposalForm', ->
  templateUrl: 'generated/components/proposal_form/proposal_form.html'
  controller: ($scope, $rootScope, proposal, AppConfig, FormService, MentionService, KeyEventService, ScrollService, EmojiService, UserHelpService, Records, AttachmentService) ->
    $scope.nineWaysArticleLink = ->
      UserHelpService.nineWaysArticleLink()

    $scope.proposalKinds = AppConfig.plugins.proposal_kinds
    $scope.proposal = proposal.clone()
    $scope.proposal.kind = $scope.proposal.kind or _.first($scope.proposalKinds)

    actionName = if $scope.proposal.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.proposal,
      flashSuccess: "proposal_form.messages.#{actionName}"
      draftFields: ['name', 'description']
      successEvent: 'proposalCreated'
      successCallback: ->
        $rootScope.$broadcast 'setSelectedProposal'
        Records.attachments.find(attachableId: proposal.id, attachableType: 'Motion')
                           .filter (attachment) -> !_.contains(proposal.attachment_ids, attachment.id)
                           .map    (attachment) -> attachment.remove()
        ScrollService.scrollTo('#current-proposal-card-heading')

    $scope.descriptionSelector = '.proposal-form__details-field'

    EmojiService.listen $scope, $scope.proposal, 'description', $scope.descriptionSelector

    KeyEventService.submitOnEnter $scope
    MentionService.applyMentions $scope, $scope.proposal
    AttachmentService.listenForAttachments $scope, $scope.proposal
