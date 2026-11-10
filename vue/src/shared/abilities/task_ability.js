import Session from '@/shared/services/session';
import CommentAbility from '@/shared/abilities/comment_ability';
import DiscussionAbility from '@/shared/abilities/discussion_ability';
import PollAbility from '@/shared/abilities/poll_ability';

// Whether the current user can tick tasks in a record's text. People mentioned
// in a task can also tick it; the caller checks that.
export default {
  canUpdate(record) {
    if (!record) { return false; }
    if (record.isA('discussion')) { return DiscussionAbility.canUpdate(record); }
    if (record.isA('comment')) { return CommentAbility.canUpdate(record); }
    if (record.isA('poll')) { return PollAbility.canUpdate(record); }
    if (record.isA('stance')) { return record.poll().group().isEnabled() && Session.user() === record.author(); }
    return false;
  }
};
