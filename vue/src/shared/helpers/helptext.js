import Records from '@/shared/services/records';
import {includes} from 'lodash-es';
import I18n from '@/i18n';


// a series of helpers related to getting a translation string to translate, such
// as the headline of an event or the helptext strings on the discussion or group forms

export var eventHeadline = function(event, useNesting) {
  if (useNesting == null) { useNesting = false; }
  const key = (() => { switch (event.kind) {
    case 'new_comment':       return newCommentKey(event, useNesting);
    case 'stance_created':    return stanceCreatedKey(event, useNesting);
    case 'discussion_edited': return discussionEditedKey(event);
    case 'poll_created': return 'poll_created';
    default: return event.kind;
  } })();
  return `thread_item.${key}`;
};

export var eventTitle = function(event) {
  switch (event.eventableType) {
    case 'Comment':             return event.model().parentAuthorName;
    case 'Poll': case 'Outcome':     return event.model().poll().title;
    case 'Group': case 'Membership': return event.model().group().name;
    case 'Stance':              return event.model().poll().title;
    case 'Discussion':
      if (event.kind === 'discussion_moved') {
        if (event.sourceGroupId) {
          return (Records.groups.find(event.sourceGroupId) || {fullName: I18n.t('thread_item.deleted_group')}).fullName;
        } else {
          return I18n.t('thread_item.invite_only_thread');
        }
      } else {
        return event.model().title;
      }
  }
};

export var eventPollType = function(event) {
  if (!includes(['Poll', 'Stance', 'Outcome'], event.eventableType)) { return ""; }
  return `poll_types.${event.model().poll().pollType}`;
};

export var emojiTitle = shortname => `reactions.${shortname.replace(/:/g, '')}`;

export var groupPrivacy = function(group, privacy) {
  privacy = privacy || group.groupPrivacy;

  if (group.isParent()) {
    switch (privacy) {
      case 'open':   return 'group_form.group_privacy_is_open_description';
      case 'secret': return 'group_form.group_privacy_is_secret_description';
      case 'closed':
        if (group.allowPublicThreads) {
          return 'group_form.group_privacy_is_closed_public_threads_description';
        } else {
          return 'group_form.group_privacy_is_closed_description';
        }
    }
  } else {
    switch (privacy) {
      case 'open':   return 'group_form.subgroup_privacy_is_open_description';
      case 'secret': return 'group_form.subgroup_privacy_is_secret_description';
      case 'closed':
        if (group.isSubgroupOfSecretParent()) {
          return 'group_form.subgroup_privacy_is_closed_secret_parent_description';
        } else if (group.allowPublicThreads) {
          return 'group_form.subgroup_privacy_is_closed_public_threads_description';
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

var newCommentKey = function(event, useNesting) {
  if (event.isNested() && !useNesting) {
    return 'comment_replied_to';
  } else {
    return 'new_comment';
  }
};

var stanceCreatedKey = function(event, useNesting) {
  if (event.isNested() && useNesting) {
    return 'new_comment';
  } else {
    return 'stance_created';
  }
};

var discussionEditedKey = function(event) {
  const changes = event.customFields.changed_keys;
  if (includes(changes, 'title')) {
    return 'discussion_title_edited';
  } else if (includes(changes, 'private')) {
    return 'discussion_privacy_edited';
  } else if (includes(changes, 'description')) {
    return 'discussion_context_edited';
  } else if (includes(changes, 'document_ids')) {
    return 'discussion_attachments_edited';
  } else {
    return 'discussion_edited';
  }
};
