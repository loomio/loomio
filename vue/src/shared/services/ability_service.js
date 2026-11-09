import AppConfig     from '@/shared/services/app_config';
import Records       from '@/shared/services/records';
import Session       from '@/shared/services/session';
import LmoUrlService from '@/shared/services/lmo_url_service';
import PollAbility   from '@/shared/abilities/poll_ability';
import CommentAbility from '@/shared/abilities/comment_ability';
import DiscussionAbility from '@/shared/abilities/discussion_ability';
import TopicAbility from '@/shared/abilities/topic_ability';
import GroupAbility from '@/shared/abilities/group_ability';
import {intersection} from 'lodash-es';

export default new class AbilityService {
  isNotEmailVerified() {
    return Session.isSignedIn() && !Session.user().emailVerified;
  }

  isEmailVerified() {
    return Session.isSignedIn() && Session.user().emailVerified;
  }

  isUser() {
    return Session.isSignedIn();
  }

  canContactUser(user) {
    return Session.isSignedIn() &&
    (Session.userId !== user.id) &&
    intersection(Session.user().groupIds(), user.groupIds()).length;
  }

  canAddReaction(topic) {
    return topic.group().isEnabled() && !topic.lockedAt && topic.allowReactions && topic.membersInclude(Session.user());
  }

  canAttachFiles(model) {
    const kind = model.constructor.singular;
    if (!['discussion', 'poll', 'comment', 'stance', 'outcome'].includes(kind)) { return true; }
    if (['discussion', 'poll'].includes(kind) && !model.topicId) { return true; }
    const topic = kind === 'outcome' ? model.poll().topic() : model.topic();
    return !topic.attachmentsAdminOnly || topic.adminsInclude(Session.user());
  }

  canEdit(model) {
    if (!model) { return false; }

    return (model.isA('discussion') && DiscussionAbility.update(model)) ||
    (model.isA('comment') && CommentAbility.update(model)) ||
    (model.isA('poll') && PollAbility.update(model)) ||
    (model.isA('stance') && this.canEditStance(model));
  }

  canEditStance(stance) {
    return stance.poll().group().isEnabled() && Session.user() === stance.author();
  }

  canAdminTags(topic) {
    const group = topic.group();
    return group.isEnabled() && group.parentOrSelf().adminsInclude(Session.user());
  }

  canCreateTags(group) {
    const user = Session.user();
    return group.parentOrSelf().adminsInclude(user) ||
      group.adminsInclude(user) ||
      !!(group.membersCanCreateTags && group.membersInclude(user));
  }

  canAdminister(model) {
    if (model.constructor.singular == 'group') {
      return GroupAbility.update(model);
    } else {
      return model.topic().group().isEnabled() && model.topic().adminsInclude(Session.user());
    }
  }

  canAnnounce(model) {
    if (model.isA('group')) { return GroupAbility.notify(model); }
    if (model.isA('poll')) { return PollAbility.announce(model); }
    if (model.isA('topic')) { return !model.lockedAt && TopicAbility.announce(model); }
    return DiscussionAbility.announce(model);
  }

  canAddGuests(model) {
    if (model.isA('group')) { return GroupAbility.addMembers(model); }
    if (model.isA('poll')) { return PollAbility.addGuests(model); }
    if (model.isA('topic')) { return TopicAbility.addGuests(model); }
    return this.canAddGuestsDiscussion(model);
  }

  canAddGuestsDiscussion(discussion) {
    if (discussion.groupId) {
      return discussion.group().isEnabled() && !!discussion.group().parentOrSelf().subscription?.allow_guests &&
      (discussion.group().adminsInclude(Session.user()) ||
      (discussion.group().membersCanAddGuests && discussion.group().membersInclude(Session.user())));
    } else {
      return !discussion.id || discussion.topic().adminsInclude(Session.user());
    }
  }

  canStartGroups() {
    return this.isEmailVerified() && (AppConfig.features.app.create_group || Session.user().isAdmin);
  }

  canTranslate(model) {
    return !model.discardedAt &&
           AppConfig.inlineTranslation.isAvailable &&
           !model.translationId &&
           model.contentLocale &&
           model.contentLocale !== Session.user().locale &&
           !model.isBlank() &&
           Session.isSignedIn()
  }

  canUntranslate(model) {
    return !!model.translationId
  }

}
