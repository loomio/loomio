import BaseModel from '@/shared/record_store/base_model';
import AppConfig from '@/shared/services/app_config';
import compareAsc from 'date-fns/compareAsc';
import {each, invokeMap} from 'lodash';

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
      volume: null
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

  saveVolume(volume, applyToAll) {
    if (applyToAll == null) { applyToAll = false; }
    this.processing = true;
    return this.remote.patchMember(this.keyOrId(), 'set_volume', {
      volume,
      apply_to_all: applyToAll,
      unsubscribe_token: this.user().unsubscribeToken
    }
    ).then(() => {
      if (applyToAll) {
        this.recordStore.discussions.collection.find({ groupId: { $in: this.group().organisationIds() } }).forEach(discussion => discussion.update({discussionReaderVolume: null}));
        return each(this.user().memberships(), membership => membership.update({volume}));
      } else {
        return each(this.group().discussions(), discussion => discussion.update({discussionReaderVolume: null}));
      }
  }).finally(() => {
      return this.processing = false;
    });
  }

  resend() {
    return this.remote.postMember(this.keyOrId(), 'resend').then(() => {
      return this.resent = true;
    });
  }

  isMuted() {
    return this.volume === 'mute';
  }

  beforeRemove() {
    return invokeMap(this.recordStore.events.find({'eventableType': 'membership', 'eventableId': this.id}), 'remove');
  }
};
