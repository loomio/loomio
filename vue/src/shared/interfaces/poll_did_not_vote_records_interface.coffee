BaseRecordsInterface = require '@/shared/record_store/base_records_interface'
PollDidNotVoteModel  = require '@/shared/models/poll_did_not_vote_model'

export default class PollDidNotVoteRecordsInterface extends BaseRecordsInterface
  model: PollDidNotVoteModel
