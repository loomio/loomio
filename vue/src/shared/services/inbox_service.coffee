import Records            from '@/shared/services/records'
import Session            from '@/shared/services/session'
import ThreadFilter       from '@/shared/services/thread_filter'

export default new class InboxService

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
      @query().length
    else
      "..."

  query: -> ThreadFilter(Records, filters: @filters)
