BaseRecordsInterface = require 'shared/interfaces/base_records_interface.coffee'
PollDidNotVoteModel  = require 'shared/models/poll_did_not_vote_model.coffee'

module.exports = class PollDidNotVoteRecordsInterface extends BaseRecordsInterface
  model: PollDidNotVoteModel
