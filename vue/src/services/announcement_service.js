import EventBus       from '@/services/event_bus';
import AbilityService from '@/services/ability_service';
import Session from '@/services/session';
import Records from '@/services/records';

const user = () => Session.user();
export default new class AnnouncementService {
  audiencesFor(model) {
    const audiences = [];

    if (model.discussion && model.discussion().id && model.discussion().membersCount) {
      model.adminsInclude(user()) ||
       (model.group().membersCanAnnounce && model.membersInclude(user()));
      audiences.push('discussion_group');
    }

    if (model.poll && model.poll().id && model.poll().votersCount) {
      model.adminsInclude(user()) ||
       (model.group().membersCanAnnounce && model.membersInclude(user()));
      audiences.push('voters');
    }

    if (model.poll && model.poll().id && model.poll().decidedVotersCount && model.poll().undecidedVotersCount) {
      model.adminsInclude(user()) ||
       (model.group().membersCanAnnounce && model.membersInclude(user()));
      audiences.push('decided_voters');
    }

    if (model.poll && model.poll().id && model.poll().decidedVotersCount && model.poll().undecidedVotersCount) {
      model.adminsInclude(user()) ||
       (model.group().membersCanAnnounce && model.membersInclude(user()));
      audiences.push('undecided_voters');
    }

    return audiences;
  }
};
