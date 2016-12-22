angular.module('loomioApp').factory 'PollRecordsInterface', (BaseRecordsInterface, PollModel) ->
  class PollRecordsInterface extends BaseRecordsInterface
    model: PollModel

    buildProposal: ->
      @build(pollOptionIds: [])

    buildEngagement: ->

    buildPoll: ->
