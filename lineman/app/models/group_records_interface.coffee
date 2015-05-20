angular.module('loomioApp').factory 'GroupRecordsInterface', (BaseRecordsInterface, GroupModel, $q) ->
  class GroupRecordsInterface extends BaseRecordsInterface
    model: GroupModel

    fetchByParent: (parentGroup) ->
      @fetch
        path: "#{parentGroup.id}/subgroups"
        cacheKey: "subgroupsFor#{parentGroup.key}"

    findOrFetchForSubdomain: (subdomain) ->
      deferred = $q.defer()
      promise = @fetch(
        path: 'for_subdomain'
        params:
          subdomain: subdomain).then => @find(subdomain: subdomain)[0]

      if record = @find(subdomain: subdomain)[0]
        deferred.resolve(record)
      else
        deferred.resolve(promise)

      deferred.promise
