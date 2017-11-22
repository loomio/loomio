angular.module('loomioApp').factory 'ThreadPositionService', ->
  new class ThreadPositionService
    initialPosition: (discussion) ->
      switch
        when discussion.requestedSequenceId
          "requested"
        when (!discussion.lastReadAt) || discussion.itemsCount == 0
          'context'
        when discussion.readItemsCount() == 0
          'beginning'
        when discussion.isUnread()
          'unread'
        else
          'latest'

    initialSequenceId: (position, discussion, per) ->
      switch position
        when "requested"            then discussion.requestedSequenceId
        when "beginning", "context" then discussion.firstSequenceId()
        when "unread"               then discussion.firstUnreadSequenceId()
        when "latest"               then discussion.lastSequenceId() - per + 2

    elementToFocus: (position, discussion) ->
      switch position
        when "context"   then ".context-panel h1"
        when "requested" then "#sequence-#{discussion.requestedSequenceId}"
        when "beginning" then "#sequence-#{discussion.firstSequenceId()}"
        when "unread"    then "#sequence-#{discussion.firstUnreadSequenceId()}"
        when "latest"    then "#sequence-#{discussion.lastSequenceId()}"
