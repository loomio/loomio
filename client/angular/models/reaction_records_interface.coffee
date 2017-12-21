angular.module('loomioApp').factory 'ReactionRecordsInterface', (BaseRecordsInterface, ReactionModel) ->
  class ReactionRecordsInterface extends BaseRecordsInterface
    model: ReactionModel
