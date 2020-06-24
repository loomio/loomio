import { debounce, forEach } from 'lodash'
import Records from '@/shared/services/records'

ids = {
  comment_ids: []
  discussion_ids: []
  poll_ids: []
  outcome_ids: []
}

export default new class ReactionService
  enqueueFetch: (model) ->
    ids['comment_ids'].push(model.id) if model.isA?('comment')
    ids['discussion_ids'].push(model.id) if model.isA?('discussion')
    ids['poll_ids'].push(model.id) if model.isA?('poll')
    ids['outcome_ids'].push(model.id) if model.isA?('outcome')
    @fetchEnqueued()

  fetchEnqueued: debounce ->
    if ids['comment_ids'].length > 0
      Records.reactions.fetch(params: @jsonify_ids(ids))
    ids = {comment_ids: [], discussion_ids: [], poll_ids: [], outcome_ids: []}
  , 5000

  jsonify_ids: (ids) ->
    o = {}
    forEach ids, (v, k) ->
      o[k] = JSON.stringify(v)
    o
