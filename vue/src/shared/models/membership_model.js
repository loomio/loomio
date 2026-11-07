import BaseModel from '@/shared/record_store/base_model';
import Session from '@/shared/services/session';
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
      revokedAt: null,
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
    this.processing = true;
    return Records.memberships.remote.destroy(this.keyOrId()).then(response => {
      // Match the server's retained record so membership lookups stay reactive.
      this.update({revokedAt: new Date()});
      if (this.userId === Session.userId) {
        Records.memberships.revokeGroupAccess(groupIds);
      }
      return response;
    }).finally(() => {
      this.processing = false;
    });
  }

  beforeRemove() {
    return invokeMap(Records.topicItems.find({'itemableType': 'membership', 'itemableId': this.id}), 'remove');
  }
};
