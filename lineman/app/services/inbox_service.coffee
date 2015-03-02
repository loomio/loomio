angular.module('loomioApp').factory 'InboxService', (UserAuthService, Records) ->
  new class InboxService
    constructor: ->
      currentUser = UserAuthService.currentUser
      baseThreadsView = (name) ->
       view = Records.discussions.collection.addDynamicView(name)
       #view.applyFind(groupId: $in: currentUser.groupIds())
       #view.applyFind(volume: $in: ['email', 'normal'])
       view

      @currentView = baseThreadsView('currentDiscussions')
      #@currentView.applyFind(lastActivityAt: {'$gte': moment(4 weeks ago)})
      @currentView.applySimpleSort('lastActivityAt', true) # desc.. maybe try created at for a buzz.

      @unreadView = baseThreadsView('unreadDiscussions')
      @unreadView.applySimpleSort('lastActivityAt', true) # desc.. maybe try created at for a buzz.
      @unreadView.applyWhere (discussion) -> discussion.isUnread()

    fetchRecords: ->
      Records.discussions.fetchInboxUnread()
      Records.discussions.fetchInboxCurrent().then (response) ->
        console.log 'inbox current:', response


    currentThreads: ->
      @currentView.data()

    unreadThreads: ->
      @unreadView.data()

      #fetch the records we need and subscribe via faye to new records, and if connection is broken refresh.
      #would be good to know if we lose connection and need to refresh.
      #consider detecting if server contact is lost via websocket.

