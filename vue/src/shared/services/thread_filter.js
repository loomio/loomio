import Session from '@/shared/services/session';
import Records from '@/shared/services/records';
import { subWeeks } from 'date-fns';
import { each, compact } from 'lodash';

export default function(options) {
  let chain = Records.discussions.collection.chain();
  chain = chain.find({discardedAt: null});
  if (options.group) { chain = chain.find({groupId: { $in: options.group.organisationIds() }}); }
  if (options.from) { chain = chain.find({lastActivityAt: { $gt: options.from }}); }
  if (options.to) { chain = chain.find({lastActivityAt: { $lt: options.to }}); }

  if (options.ids) {
    chain = chain.find({id: {$in: options.ids}});
  } else {
    each(compact([].concat(options.filters)), filter => chain = (() => { switch (filter) {
      case 'show_recent':    return chain.find({lastActivityAt: { $gt: subWeeks(new Date, 6) }});
      case 'show_unread':    return chain.where(thread => thread.isUnread());
      case 'hide_unread':    return chain.where(thread => !thread.isUnread());
      case 'show_dismissed': return chain.where(thread => thread.isDismissed());
      case 'hide_dismissed': return chain.where(thread => !thread.isDismissed());
      case 'show_closed':    return chain.where(thread => thread.closedAt != null);
      case 'show_opened':    return chain.find({closedAt: null});
      case 'show_pinned':    return chain.find({pinned: true});
      case 'hide_pinned':    return chain.find({pinned: false});
      case 'show_muted':     return chain.where(thread => thread.volume() === 'mute');
      case 'hide_muted':     return chain.where(thread => thread.volume() !== 'mute');
      case 'show_proposals': return chain.where(thread => thread.hasDecision());
      case 'hide_proposals': return chain.where(thread => !thread.hasDecision());
      case 'only_threads_in_my_groups':
        var userGroupIds = Session.user().groupIds();
        return chain.find({$or: [
          {$and: [
            {inviterId: {$ne: null}},
            {revokedAt: null}
          ]},
          {groupId: {$in: userGroupIds}}
        ]});
    } })());
  }
  return chain.simplesort('lastActivityAt', true).data();
}
