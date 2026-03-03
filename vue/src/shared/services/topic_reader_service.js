import Session       from '@/shared/services/session';
import Records       from '@/shared/services/records';
import Flash         from '@/shared/services/flash';

export default new class TopicReaderService {
  constructor() {
    this.makeAdmin = {
      name: 'membership_dropdown.make_coordinator',
      canPerform(tr) {
        return !tr.topic().group().adminsInclude(tr.user()) &&
        !tr.admin && tr.topic().adminsInclude(Session.user());
      },
      perform(tr) {
        return Records.topicReaders.remote.postMember(tr.id, 'make_admin');
      }
    }

    this.removeAdmin = {
      name: 'membership_dropdown.revoke_admin',
      canPerform(tr) {
        return tr.admin && tr.topic().adminsInclude(Session.user());
      },
      perform(tr) {
        return Records.topicReaders.remote.postMember(tr.id, 'remove_admin');
      }
    };

    this.resend = {
      name: 'membership_dropdown.resend',
      canPerform(tr) {
        return tr.topic().adminsInclude(Session.user());
      },
      perform(tr) {
        return Records.topicReaders.remote.postMember(tr.id, 'resend')
        .then(() => Flash.success("membership_dropdown.invitation_resent"));
      }
    };

    this.revoke = {
      name: 'membership_dropdown.remove_from.discussion',
      canPerform(tr) {
        return tr.guest && tr.topic().adminsInclude(Session.user());
      },
      perform(tr) {
        return Records.topicReaders.remote.postMember(tr.id, 'revoke')
        .then(() => Flash.success("membership_remove_modal.invitation.flash"));
      }
    };
  }
}
