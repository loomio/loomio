import Session from '@/shared/services/session';
import CommentAbility from '@/shared/abilities/comment_ability';
import DiscussionAbility from '@/shared/abilities/discussion_ability';
import GroupAbility from '@/shared/abilities/group_ability';
import OutcomeAbility from '@/shared/abilities/outcome_ability';
import PollAbility from '@/shared/abilities/poll_ability';
import StanceAbility from '@/shared/abilities/stance_ability';

// Mirrors the server's Ability::Task :update, which decides who can tick a
// task in a record's text. test/contracts/task_ability_contract_test.rb checks
// it. `task` describes the task item: its author and whether it mentions the
// current user.
export default {
  canUpdate(record, task) {
    if (!record) { return false; }
    if (!record.isA('user') && !record.group().isEnabled()) { return false; }
    return task.authorId === Session.user().id || task.mentioned || this.canUpdateRecord(record);
  },

  canUpdateRecord(record) {
    if (record.isA('discussion')) { return DiscussionAbility.canUpdate(record); }
    if (record.isA('comment')) { return CommentAbility.canUpdate(record); }
    if (record.isA('poll')) { return PollAbility.canUpdate(record); }
    if (record.isA('stance')) { return StanceAbility.canUpdate(record); }
    if (record.isA('outcome')) { return OutcomeAbility.canUpdate(record); }
    if (record.isA('group')) { return GroupAbility.canUpdate(record); }
    if (record.isA('user')) { return record.id === Session.user().id; }
    return false;
  }
};
