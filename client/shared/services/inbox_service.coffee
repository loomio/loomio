Records            = require 'shared/services/records.coffee'
Session            = require 'shared/services/session.coffee'
ThreadQueryService = require 'shared/services/thread_query_service.coffee'

module.exports = new class InboxService

  filters: [
    'only_threads_in_my_groups',
    'show_unread',
    'show_recent',
    'hide_muted',
    'hide_dismissed'
  ],

  load: (options = {}) ->
    Records.discussions.fetchInbox(options).then => @loaded = true

  unreadCount: ->
    if @loaded
      @query().length()
    else
      "..."

  query: ->
    ThreadQueryService.queryFor(name: "inbox", filters: @filters)

  queryByGroup: ->
    _.fromPairs _.map Session.user().inboxGroups(), (group) =>
      [
        group.key,
        ThreadQueryService.queryFor(name: "group_#{group.key}_inbox", filters: @filters, group: group)
      ]
