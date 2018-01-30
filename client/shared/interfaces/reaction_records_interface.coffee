BaseRecordsInterface = require 'shared/record_store/base_records_interface.coffee'
ReactionModel        = require 'shared/models/reaction_model.coffee'

module.exports = class ReactionRecordsInterface extends BaseRecordsInterface
  model: ReactionModel
