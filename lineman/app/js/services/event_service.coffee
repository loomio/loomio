angular.module('loomioApp').factory 'EventService', ($http, MainRecordStore, EventModel) ->
  new class EventService
    fetch: (params, success, failure) ->
      $http.get("/api/v1/events?discussion_id=#{params.discussion_id}&page=#{params.page}").then (response) =>
        console.log response
        MainRecordStore.importRecords(response.data)

        # return discussions in the order they arrived
        ordered_ids = _.map response.data.events, (event) -> event.id
        events = MainRecordStore.events.get(ordered_ids)
        success(events)
      , (response) ->
        failure(response.data.error)
