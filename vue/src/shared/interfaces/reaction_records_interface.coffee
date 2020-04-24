import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import ReactionModel        from '@/shared/models/reaction_model'
import { debounce } from 'lodash-es'

export default class ReactionRecordsInterface extends BaseRecordsInterface
  model: ReactionModel

  # @queue = {}
  # enqueueFetch: (reactionParams) ->
  #   if @queue[rectionParams.reactableType]?
  #     @queue[rectionParams.reactableType].push rectionParams.reactableId
  #   else
  #     @queue[rectionParams.reactableType] = [reactionParams.reactableId]
  #
  # debouncedFetch: debounce =>
  #   @fetch
  #     path: 'batch'
  #     params:
  #       queue: @queue
