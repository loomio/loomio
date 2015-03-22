angular.module('loomioApp').factory 'InboxService', (UserAuthService, Records) ->
  new class InboxService
    constructor: ->
      baseThreadsView = (name) ->
       Records.discussions.collection.addDynamicView(name)

      @currentView = baseThreadsView('currentDiscussions')
      @currentView.applySimpleSort('lastActivityAt', true) # desc.. maybe try created at for a buzz.

      @unreadView = baseThreadsView('unreadDiscussions')
      @unreadView.applySimpleSort('lastActivityAt', true) # desc.. maybe try created at for a buzz.
      @unreadView.applyWhere (discussion) -> discussion.isUnread()

    fetchRecords: ->
      Records.discussions.fetchInboxByDate
      Records.discussions.fetchInboxByDate(filter: 'unread')


    currentThreads: ->
      @currentView.data()

    unreadThreads: ->
      @unreadView.data()

      #fetch the records we need and subscribe via faye to new records, and if connection is broken refresh.
      #would be good to know if we lose connection and need to refresh.
      #consider detecting if server contact is lost via websocket.

