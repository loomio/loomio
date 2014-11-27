angular.module('loomioApp').factory 'EventService', ($http, Records, EventModel) ->
  new class EventService
    fetch: (params, success, failure) ->
      $http.get("/api/v1/events?discussion_id=#{params.discussion_id}&page=#{params.page}").then (response) =>
        Records.import(response.data)
        # return discussions in the order they arrived
        orderedIds = _.map response.data.events, (event) -> event.id
        events = Records.events.get(orderedIds)
        success(events)
      , (response) ->
        failure(response.data.error)
