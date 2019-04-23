import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import Vue from 'vue'
export default new class ThreadQueryService

  queryFor: (options = {}) ->
    Records.discussions.collection.removeDynamicView(options.name) if options.overwrite
    return {
      threads: -> applyFilters(options).data()
      length:  -> @threads().length
      any: -> @length() > 0
      constructor:
        singular: 'query'
    }

  applyFilters = (options) ->
    return view if view = Records.discussions.collection.getDynamicView(options.name)

    view = Records.discussions.collection.addDynamicView(options.name)
    view.applyFind(groupId: { $in: options.group.organisationIds() })      if options.group
    view.applyFind(lastActivityAt: { $gt: parseTimeOption(options.from) }) if options.from
    view.applyFind(lastActivityAt: { $lt: parseTimeOption(options.to) })   if options.to

    if options.ids
      view.applyFind(id: {$in: options.ids})
    else
      _.each [].concat(options.filters), (filter) ->
        switch filter
          when 'show_recent'    then view.applyFind(lastActivityAt: { $gt: moment().startOf('day').subtract(6, 'week').toDate() })
          when 'show_unread'    then view.applyWhere (thread) -> thread.isUnread()
          when 'hide_unread'    then view.applyWhere (thread) -> !thread.isUnread()
          when 'show_dismissed' then view.applyWhere (thread) -> thread.isDismissed()
          when 'hide_dismissed' then view.applyWhere (thread) -> !thread.isDismissed()
          when 'show_closed'    then view.applyWhere (thread) -> thread.closedAt?
          when 'show_opened'    then view.applyFind(closedAt: null)
          when 'show_pinned'    then view.applyFind(pinned: true)
          when 'hide_pinned'    then view.applyFind(pinned: false)
          when 'show_muted'     then view.applyWhere (thread) -> thread.volume() == 'mute'
          when 'hide_muted'     then view.applyWhere (thread) -> thread.volume() != 'mute'
          when 'show_proposals' then view.applyWhere (thread) -> thread.hasDecision()
          when 'hide_proposals' then view.applyWhere (thread) -> !thread.hasDecision()
          when 'only_threads_in_my_groups'
            userGroupIds = Session.user().groupIds()
            view.applyFind $or: [
              {guestGroupId: {$in: userGroupIds}}
              {groupId: {$in: userGroupIds}}
            ]

    Vue.observable(view)

  parseTimeOption = (options) ->
    # we pass times in something human-readable like '1 month ago'
    # this translates that into today.subtract(1, 'month')
    parts = options.split ' '
    moment().startOf('day').subtract(parseInt(parts[0]), parts[1])
