angular.module('loomioApp').factory 'EventRecordsInterface', (BaseRecordsInterface, EventModel) ->
  class EventRecordsInterface extends BaseRecordsInterface
    @model: EventModel

    fetch: (params, success, failure) ->
      @restfulClient.get("?discussion_id=#{params.discussion_id}&page=#{params.page}").then (response) =>
        @recordStore.import(response.data)
        # return discussions in the order they arrived
        orderedIds = _.map response.data.events, (event) -> event.id
        events = @recordStore.events.get(orderedIds)
        success(events)
      , (response) ->
        failure(response.data.error)
