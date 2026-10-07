import {includes} from 'lodash-es';
import { I18n } from '@/i18n';

export var eventHeadline = function(topic_item) {
  const key = (() => { switch (topic_item.kind) {
    case 'new_comment':       return 'new_comment';
    case 'stance_created':    return 'new_comment';
    case 'stance_updated':    return 'new_comment';
    case 'discussion_edited': return 'discussion_edited';
    case 'discussion_moved':  return 'discussion_moved_without_source';
    case 'discussion_closed': return 'thread_locked';
    case 'discussion_reopened': return 'thread_unlocked';
    case 'poll_created': return 'poll_created';
    default: return topic_item.kind;
  } })();
  return `thread_item.${key}`;
};

export var eventTitle = function(topic_item) {
  switch (topic_item.itemableType) {
    case 'Comment':             return topic_item.model().parentAuthorName;
    case 'Poll': case 'Outcome':     return topic_item.model().poll().title;
    case 'Group': case 'Membership': return topic_item.model().group().name;
    case 'Stance':              return topic_item.model().poll().title;
    case 'Discussion':          return topic_item.model().title;
  }
};

export var eventPollType = function(topic_item) {
  if (!includes(['Poll', 'Stance', 'Outcome'], topic_item.itemableType)) { return ""; }
  return `poll_types.${topic_item.model().poll().pollType}`;
};

export var emojiTitle = shortname => `reactions.${shortname.replace(/:/g, '')}`;

export var groupPrivacy = function(group, privacy) {
  privacy = privacy || group.groupPrivacy;

  if (group.isParent()) {
    switch (privacy) {
      case 'open':   return 'group_form.group_privacy_is_open_description';
      case 'secret': return 'group_form.group_privacy_is_secret_description';
      case 'closed': return 'group_form.group_privacy_is_closed_description';
    }
  } else {
    switch (privacy) {
      case 'open':   return 'group_form.subgroup_name_and_content_are_public';
      case 'secret': return 'group_form.subgroup_privacy_is_secret_description';
      case 'closed': return 'group_form.subgroup_name_is_public_and_threads_are_private';
      case 'parent_members': return 'group_form.subgroup_is_visible_to_parent_members';
    }
  }
};

export function groupPrivacyOptions(group) {
  if (!group.parentId) { return ['open', 'closed', 'secret']; }
  if (['secret', 'parent_members'].includes(group.parent().groupPrivacy)) { return ['parent_members', 'secret']; }
  return ['open', 'closed', 'parent_members', 'secret'];
}

export function groupMembershipGrantedUpon(group, granted) {
  if (['request', 'approval'].includes(granted) && group.privacyIsParentMembers()) {
    return 'group_form.membership_granted_upon_' + granted + '_parent_members';
  }
  return 'group_form.membership_granted_upon_' + granted;
}

export var groupPrivacyStatement = function(group) {
  switch (group.groupPrivacy) {
    case 'open':
    case 'closed': return 'group_form.privacy_statement.public_on_web';
    case 'parent_members': return 'group_form.privacy_statement.private_to_parent_members';
    case 'secret': return 'group_form.privacy_statement.private_to_group';
  }
};

export var groupPrivacyConfirm = function(group) {
  if (group.isNew()) { return ""; }

  if (group.attributeIsModified('groupPrivacy')) {
    if (group.privacyIsSecret()) {
      if (group.isParent()) {
        return 'group_form.confirm_change_to_secret';
      } else {
        return 'group_form.confirm_change_to_secret_subgroup';
      }
    } else if (group.privacyIsOpen()) {
      return 'group_form.confirm_change_to_public';
    }
  } else if (group.attributeIsModified('discussionPrivacyOptions')) {
    if (group.discussionPrivacyOptions === 'private_only') {
      return 'group_form.confirm_change_to_private_discussions_only';
    }
  }
};
