import Session from '@/shared/services/session';

const user = () => Session.user();
export default new class AnnouncementService {
  audiencesFor(model) {
    const audiences = [];

    if (model.topic) {
      const topic = model.topic();
      if (topic && topic.membersCount) {
        audiences.push('discussion_group');
      }
    }

    if (model.poll) {
      const poll = model.poll();
      if (poll && poll.id && poll.votersCount) {
        model.adminsInclude(user()) ||
         (model.group() && model.group().membersCanAnnounce && model.membersInclude(user()));
        audiences.push('voters');
      }

      if (poll && poll.id && poll.decidedVotersCount && poll.undecidedVotersCount) {
        model.adminsInclude(user()) ||
         (model.group() && model.group().membersCanAnnounce && model.membersInclude(user()));
        audiences.push('decided_voters');
      }

      if (poll && poll.id && poll.decidedVotersCount && poll.undecidedVotersCount) {
        model.adminsInclude(user()) ||
         (model.group() && model.group().membersCanAnnounce && model.membersInclude(user()));
        audiences.push('undecided_voters');
      }
    }

    return audiences;
  }
};
