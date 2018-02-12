BaseRecordsInterface = require 'shared/record_store/base_records_interface.coffee'
GroupModel           = require 'shared/models/group_model.coffee'

module.exports = class GroupRecordsInterface extends BaseRecordsInterface
  model: GroupModel

  fuzzyFind: (id) ->
    # could be id or key or handle
    @find(id) || _.first(@find(handle: id))

  findOrFetch: (id, options = {}) ->
    record = @fuzzyFind(id)
    if record
      Promise.resolve(record)
    else
      @remote.fetchById(id, options).then => @fuzzyFind(id)

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
