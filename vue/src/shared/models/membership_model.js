import BaseModel from '@/shared/record_store/base_model';
import AppConfig from '@/shared/services/app_config';
import compareAsc from 'date-fns/compareAsc';
import {each, invokeMap} from 'lodash-es';
import Records from '@/shared/services/records';

export default class MembershipModel extends BaseModel {
  static singular = 'membership';
  static plural = 'memberships';
  static serializableAttributes = ['title'];
  static indices = ['userId', 'groupId'];
  static uniqueIndices = ['id'];
  static searchableFields = ['userName', 'userUsername'];

  defaultValues() {
    return {
      userId: null,
      groupId: null,
      archivedAt: null,
      inviterId: null,
      volumeEmail: null,
      volumePush: null
    };
  }

  relationships() {
    this.belongsTo('group');
    this.belongsTo('user');
    this.belongsTo('inviter', {from: 'users'});
  }

  userName() {
    return this.user().nameWithTitle(this.group());
  }

  userUsername() {
    return this.user().username;
  }

  groupName() {
    return this.group().name;
  }

  saveVolume(volumeEmail, volumePush, applyToAll) {
    if (applyToAll == null) { applyToAll = false; }
    this.processing = true;
    const params = {
      apply_to_all: applyToAll
    };
    if (volumeEmail != null) params.volume_email = volumeEmail;
    if (volumePush != null) params.volume_push = volumePush;
    return Records.memberships.remote.patchMember(this.keyOrId(), 'set_volume', params).then(() => {
      const topicAttributes = {};
      const membershipAttributes = {};
      if (volumeEmail != null) {
        topicAttributes.readerVolumeEmail = null;
        membershipAttributes.volumeEmail = volumeEmail;
      }
      if (volumePush != null) {
        topicAttributes.readerVolumePush = null;
        membershipAttributes.volumePush = volumePush;
      }
      if (applyToAll) {
        Records.discussions.collection.find({ groupId: { $in: this.group().organisationIds() } }).forEach(discussion => discussion.topic().update(topicAttributes));
        return each(this.user().memberships(), membership => membership.update(membershipAttributes));
      } else {
        return each(this.group().discussions(), discussion => discussion.topic().update(topicAttributes));
      }
  }).finally(() => {
      return this.processing = false;
    });
  }

  resend() {
    return Records.memberships.remote.postMember(this.keyOrId(), 'resend').then(() => {
      return this.resent = true;
    });
  }

  isMuted() {
    return this.volumeEmail === 'quiet' && this.volumePush === 'quiet';
  }

  destroy() {
    const groupIds = this.group().selfAndSubgroupIds();
    return super.destroy().then(response => {
      if (this.userId !== AppConfig.currentUserId) { return response; }

      // Leaving revokes topic access and active votes throughout the group tree.
      // Clear cached eligibility after success so vote reminders disappear now.
      invokeMap(Records.memberships.find({userId: this.userId, groupId: {$in: groupIds}}), 'remove');
      Records.topics.find({groupId: {$in: groupIds}}).forEach(topic => {
        topic.update({readerGuest: false, readerAdmin: false});
      });
      const polls = Records.polls.find({groupId: {$in: groupIds}}).filter(poll => poll.isVotable());
      polls.forEach(poll => poll.update({myStanceId: null, anonymousVoterEligible: false}));
      invokeMap(Records.stances.find({participantId: this.userId, pollId: {$in: polls.map(poll => poll.id)}}), 'remove');
      return response;
    });
  }

  beforeRemove() {
    return invokeMap(Records.topicItems.find({'itemableType': 'membership', 'itemableId': this.id}), 'remove');
  }
};
