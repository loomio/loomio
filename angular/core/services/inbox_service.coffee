angular.module('loomioApp').factory 'InboxService', (Session, ThreadQueryService) ->
  new class InboxService

    filters: [
      'only_threads_in_my_groups',
      'show_unread',
      'show_recent',
      'hide_muted',
      'hide_dismissed'
    ],

    unreadCount: ->
      @query().length()

    query: ->
      ThreadQueryService.queryFor(name: "inbox", filters: @filters)

    queryByGroup: ->
      _.fromPairs _.map Session.user().inboxGroups(), (group) =>
        [
          group.key,
          ThreadQueryService.queryFor(name: "#{group.key}_inbox", filters: @filters, group: group)
        ]
