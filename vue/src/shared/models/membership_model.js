import BaseModel from '@/shared/record_store/base_model';
import AppConfig from '@/shared/services/app_config';
import compareAsc from 'date-fns/compareAsc';
import {each, invokeMap} from 'lodash-es';
import Records from '@/shared/services/records';

export default class MembershipModel extends BaseModel {
  static singular = 'membership';
  static plural = 'memberships';
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
    return Records.memberships.remote.patchMember(this.keyOrId(), 'set_volume', {
      volume_email: volumeEmail,
      volume_push: volumePush,
      apply_to_all: applyToAll,
      unsubscribe_token: this.user().unsubscribeToken
    }
    ).then(() => {
      if (applyToAll) {
        Records.discussions.collection.find({ groupId: { $in: this.group().organisationIds() } }).forEach(discussion => discussion.topic().update({readerVolumeEmail: null, readerVolumePush: null}));
        return each(this.user().memberships(), membership => membership.update({volumeEmail, volumePush}));
      } else {
        return each(this.group().discussions(), discussion => discussion.topic().update({readerVolumeEmail: null, readerVolumePush: null}));
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
    return ['mute', 'quiet'].includes(this.volumeEmail) && ['mute', 'quiet'].includes(this.volumePush);
  }

  beforeRemove() {
    return invokeMap(Records.topicItems.find({'itemableType': 'membership', 'itemableId': this.id}), 'remove');
  }
};
