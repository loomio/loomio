angular.module('loomioApp').factory 'PollService', (AppConfig, Records, PollProposalForm) ->
  new class PollService

    pollForms =
      proposal: PollProposalForm
      # engagement: EngagementProposalForm
      # poll:       PollPollForm

    formFor: (pollType) ->
      pollForms[pollType]

    optionsFor: (pollType) ->
      return unless template = AppConfig.pollTemplates[pollType]
      template.poll_options_attributes
