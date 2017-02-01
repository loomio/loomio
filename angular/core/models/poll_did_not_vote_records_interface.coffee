angular.module('loomioApp').factory 'PollDidNotVoteRecordsInterface', (BaseRecordsInterface, PollDidNotVoteModel) ->
  class PollDidNotVoteRecordsInterface extends BaseRecordsInterface
    model: PollDidNotVoteModel
