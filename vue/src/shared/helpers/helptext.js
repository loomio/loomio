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
      case 'open':   return 'group_form.subgroup_privacy_is_open_description';
      case 'secret': return 'group_form.subgroup_privacy_is_secret_description';
      case 'closed':
        if (group.isSubgroupOfSecretParent()) {
          return 'group_form.subgroup_privacy_is_closed_secret_parent_description';
        } else {
          return 'group_form.subgroup_privacy_is_closed_description';
        }
    }
  }
};

export var groupPrivacyStatement = function(group) {
  if (group.parentId && group.parent().privacyIsSecret()) {
    if (group.privacyIsClosed()) {
      return 'group_form.privacy_statement.private_to_parent_members';
    } else {
      return 'group_form.privacy_statement.private_to_group';
    }
  } else {
    switch (group.groupPrivacy) {
      case 'open':   return 'group_form.privacy_statement.public_on_web';
      case 'closed': return 'group_form.privacy_statement.public_on_web';
      case 'secret': return 'group_form.privacy_statement.private_to_group';
    }
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
