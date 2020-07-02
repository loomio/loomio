import { debounce, forEach, compact } from 'lodash'
import Records from '@/shared/services/records'

# ids structure {group_id: [user_id, user_id]}
ids = {}

fetchQueue = debounce ->
  return if Object.keys(ids).length == 0
  forEach ids, (user_ids, group_id) ->
    Records.memberships.fetch(params: {group_id: group_id, user_xids: user_ids.join('x'), exclude_types: 'group user'}).then (data) ->
      console.log group_id: group_id, user_ids: user_ids, data: data
  ids = {}
, 500

export default new class MembershipService
  enqueueFetch: (user_id, group_id) ->
    if ids[group_id]?
      ids[group_id].push(user_id)
    else
      ids[group_id] = [user_id]

    fetchQueue()
