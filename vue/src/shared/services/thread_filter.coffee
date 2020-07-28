import Session from '@/shared/services/session'
import { subWeeks } from 'date-fns'
import { each } from 'lodash-es'

export default (store, options) ->
  chain = store.discussions.collection.chain()
  chain = chain.find(groupId: { $in: options.group.organisationIds() })      if options.group
  chain = chain.find(lastActivityAt: { $gt: options.from }) if options.from
  chain = chain.find(lastActivityAt: { $lt: options.to })   if options.to

  if options.ids
    chain = chain.find(id: {$in: options.ids})
  else
    each [].concat(options.filters), (filter) ->
      chain = switch filter
        when 'show_recent'    then chain.find(lastActivityAt: { $gt: subWeeks(new Date, 6) })
        when 'show_unread'    then chain.where (thread) -> thread.isUnread()
        when 'hide_unread'    then chain.where (thread) -> !thread.isUnread()
        when 'show_dismissed' then chain.where (thread) -> thread.isDismissed()
        when 'hide_dismissed' then chain.where (thread) -> !thread.isDismissed()
        when 'show_closed'    then chain.where (thread) -> thread.closedAt?
        when 'show_opened'    then chain.find(closedAt: null)
        when 'show_pinned'    then chain.find(pinned: true)
        when 'hide_pinned'    then chain.find(pinned: false)
        when 'show_muted'     then chain.where (thread) -> thread.volume() == 'mute'
        when 'hide_muted'     then chain.where (thread) -> thread.volume() != 'mute'
        when 'show_proposals' then chain.where (thread) -> thread.hasDecision()
        when 'hide_proposals' then chain.where (thread) -> !thread.hasDecision()
        when 'only_threads_in_my_groups'
          userGroupIds = Session.user().groupIds()
          chain.find $or: [
            {$and: {inviterId: {$ne: null}, revokedAt: {$ne: null}}}
            {groupId: {$in: userGroupIds}}
          ]
  chain.simplesort('lastActivityAt', true).data()
