import AppConfig     from '@/shared/services/app_config';
import Records       from '@/shared/services/records';
import Session       from '@/shared/services/session';
import LmoUrlService from '@/shared/services/lmo_url_service';
import PollAbility   from '@/shared/abilities/poll_ability';
import CommentAbility from '@/shared/abilities/comment_ability';
import DiscussionAbility from '@/shared/abilities/discussion_ability';
import TopicAbility from '@/shared/abilities/topic_ability';
import GroupAbility from '@/shared/abilities/group_ability';

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

  canAttachFiles(model) {
    const kind = model.constructor.singular;
    if (!['discussion', 'poll', 'comment', 'stance', 'outcome'].includes(kind)) { return true; }
    if (['discussion', 'poll'].includes(kind) && !model.topicId) { return true; }
    const topic = kind === 'outcome' ? model.poll().topic() : model.topic();
    return TopicAbility.canAttachFiles(topic);
  }

  canEdit(model) {
    if (!model) { return false; }

    return (model.isA('discussion') && DiscussionAbility.canUpdate(model)) ||
    (model.isA('comment') && CommentAbility.canUpdate(model)) ||
    (model.isA('poll') && PollAbility.canUpdate(model)) ||
    (model.isA('stance') && this.canEditStance(model));
  }

  canEditStance(stance) {
    return stance.poll().group().isEnabled() && Session.user() === stance.author();
  }

  canAnnounce(model) {
    if (model.isA('group')) { return GroupAbility.canNotify(model); }
    if (model.isA('poll')) { return PollAbility.canAnnounce(model); }
    if (model.isA('topic')) { return !model.lockedAt && TopicAbility.canAnnounce(model); }
    return DiscussionAbility.canAnnounce(model);
  }

  canAddGuests(model) {
    if (model.isA('group')) { return GroupAbility.canAddMembers(model); }
    if (model.isA('poll')) { return PollAbility.canAddGuests(model); }
    if (model.isA('topic')) { return TopicAbility.canAddGuests(model); }
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
