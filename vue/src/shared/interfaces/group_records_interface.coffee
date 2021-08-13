import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import GroupModel           from '@/shared/models/group_model'
import Session              from '@/shared/services/session'
import EventBus             from '@/shared/services/event_bus'
import {uniq, concat, compact, map, includes, head} from 'lodash'
import NullGroupModel   from '@/shared/models/null_group_model'


export default class GroupRecordsInterface extends BaseRecordsInterface
  model: GroupModel

  nullModel: -> new NullGroupModel()

  fuzzyFind: (id) ->
    # could be id or key or handle
    @find(id) || head(@find(handle: "#{id}".toLowerCase()))

  findOrFetch: (id, options = {}) ->
    record = @fuzzyFind(id)
    if record
      @remote.fetchById(id, options)
      Promise.resolve(record)
    else
      @remote.fetchById(id, options)
      .then (data) => @recordStore.importJSON(data)
      .then => @fuzzyFind(id)

  fetchByParent: (parentGroup) ->
    @fetch
      path: "#{parentGroup.id}/subgroups"

  fetchExploreGroups: (query, options = {}) ->
    options['q'] = query
    @fetch
      params: options

  getExploreResultsCount: (query, options = {}) ->
    options['q'] = query
    @fetch
      path: 'count_explore_results'
      params: options

  getHandle: ({name, parentHandle}) ->
    @fetch
      path: 'suggest_handle'
      params: {name: name, parent_handle: parentHandle}
