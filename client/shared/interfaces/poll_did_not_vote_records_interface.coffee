BaseRecordsInterface = require 'shared/record_store/base_records_interface'
PollDidNotVoteModel  = require 'shared/models/poll_did_not_vote_model'

module.exports = class PollDidNotVoteRecordsInterface extends BaseRecordsInterface
  model: PollDidNotVoteModel
