angular.module('loomioApp').factory 'GroupRecordsInterface', (BaseRecordsInterface, GroupModel) ->
  class GroupRecordsInterface extends BaseRecordsInterface
    model: GroupModel

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
