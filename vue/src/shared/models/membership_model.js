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
      volume: null,
      emailVolume: null,
      pushVolume: null
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
    return Records.memberships.remote.patchMember(this.keyOrId(), 'set_volume', {
      volume,
      email_volume: volume,
      push_volume: volume,
      apply_to_all: applyToAll,
      unsubscribe_token: this.user().unsubscribeToken
    }
    ).then(() => {
      if (applyToAll) {
        Records.discussions.collection.find({ groupId: { $in: this.group().organisationIds() } }).forEach(discussion => discussion.update({discussionReaderVolume: null, discussionReaderEmailVolume: null, discussionReaderPushVolume: null}));
        return each(this.user().memberships(), membership => membership.update({volume, emailVolume: volume, pushVolume: volume}));
      } else {
        return each(this.group().discussions(), discussion => discussion.update({discussionReaderVolume: null, discussionReaderEmailVolume: null, discussionReaderPushVolume: null}));
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
    return (this.emailVolume || this.volume) === 'mute';
  }

  beforeRemove() {
    return invokeMap(Records.events.find({'eventableType': 'membership', 'eventableId': this.id}), 'remove');
  }
};
