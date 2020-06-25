import { debounce, forEach, compact } from 'lodash'
import Records from '@/shared/services/records'

ids = {}
resetIds = ->
  ids = {
    comment_ids: []
    discussion_ids: []
    poll_ids: []
    outcome_ids: []
  }

resetIds()

encodeIds = (ids) ->
  o = {}
  forEach ids, (v, k) ->
    o[k] = v.join('x') || null
    true
  o

fetch = debounce ->
  return if Object.keys(encodeIds(ids)).length == 0
  Records.reactions.fetch(params: encodeIds(ids))
  resetIds()
, 500

export default new class ReactionService
  enqueueFetch: (model) ->
    ids['comment_ids'].push(model.id) if model.isA?('comment')
    ids['discussion_ids'].push(model.id) if model.isA?('discussion')
    ids['poll_ids'].push(model.id) if model.isA?('poll')
    ids['outcome_ids'].push(model.id) if model.isA?('outcome')
    fetch()
