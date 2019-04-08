BaseRecordsInterface = require '@/shared/record_store/base_records_interface'
ReactionModel        = require '@/shared/models/reaction_model'

export default class ReactionRecordsInterface extends BaseRecordsInterface
  model: ReactionModel
