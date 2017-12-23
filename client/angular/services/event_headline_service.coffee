Records = require 'shared/services/records.coffee'

angular.module('loomioApp').factory 'EventHeadlineService', ($translate) ->
  new class EventHeadlineService

    headlineFor: (event, useNesting = false) ->
      $translate.instant "thread_item.#{@headlineKeyFor(event, useNesting)}",
        author:   event.actorName() || $translate.instant('common.anonymous')
        username: event.actorUsername()
        title:    @titleFor(event)
        polltype: @pollTypeFor(event)

    headlineKeyFor: (event, useNesting) ->
      return 'new_comment' if  useNesting && event.isNested() && _.includes(["new_comment", "stance_created"], event.kind)
      switch event.kind
        when 'new_comment'       then @newCommentKey(event)
        when 'discussion_edited' then @discussionEditedKey(event)
        else event.kind

    newCommentKey: (event) ->
      if event.model().parentId?
        'comment_replied_to'
      else
        'new_comment'

    discussionEditedKey: (event) ->
      changes = event.customFields.changed_keys
      if _.contains(changes, 'title')
        'discussion_title_edited'
      else if _.contains(changes, 'private')
        'discussion_privacy_edited'
      else if _.contains(changes, 'description')
        'discussion_context_edited'
      else if _.contains(changes, 'document_ids')
        'discussion_attachments_edited'
      else
        'discussion_edited'

    titleFor: (event) ->
      switch event.eventable.type
        when 'comment'             then event.model().parentAuthorName
        when 'poll', 'outcome'     then event.model().poll().title
        when 'group', 'membership' then event.model().group().name
        when 'stance'              then event.model().poll().title
        when 'discussion'
          if event.kind == 'discussion_moved'
            Records.groups.find(event.sourceGroupId).fullName
          else
            event.model().title

    pollTypeFor: (event) ->
      poll = switch event.eventable.type
        when 'poll', 'stance', 'outcome' then event.model().poll()
      $translate.instant("poll_types.#{poll.pollType}").toLowerCase() if poll
