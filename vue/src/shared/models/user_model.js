import BaseModel from '@/shared/record_store/base_model';
import AppConfig from '@/shared/services/app_config';
import { find, filter, flatten, uniq, head, compact, map, truncate  } from 'lodash-es';

export default class UserModel extends BaseModel {
  static singular = 'user';
  static plural = 'users';
  static lazyLoad = true;
  static uniqueIndices = ['id'];

  relationships() {
    return this.hasMany('memberships');
  }

  defaultValues() {
    return {
      shortBio: '',
      shortBioFormat: 'html',
      files: [],
      imageFiles: [],
      attachments: [],
      linkPreviews: [],
      locale: AppConfig.defaultLocale,
      experiences: [],
      dateTimePref: 'day_iso'
    };
  }

  nameOrEmail() {
    return this.name || this.email || this.username || this.placeholderName;
  }

  nameOrUsername() {
    return this.name || this.username;
  }

  simpleBio() {
    return truncate((this.shortBio || '').replace(/<\/?[^>]+(>|$)/g, ""), {length: 70});
  }

  localeName() {
    return (find(AppConfig.locales, h => h.key === this.locale) || {}).name;
  }

  adminMemberships() {
    return this.recordStore.memberships.find({userId: this.id, admin: true});
  }

  groupIds() {
    return map(this.memberships(), 'groupId');
  }

  groups() {
    return this.recordStore.groups.collection.chain().
      find({id: { $in: this.groupIds() }, archivedAt: null}).
      simplesort('fullName').data();
  }

  participantIds() { return []; }
  parentGroups() {
    return filter(this.groups(), group => !group.parentId);
  }

  inboxGroups() {
    return flatten([this.parentGroups(), this.orphanSubgroups()]);
  }

  allThreads() {
    return flatten(this.groups().map(group => group.discussions())
    );
  }

  orphanSubgroups() {
    return filter(this.groups(), group => {
      return group.parentId && !group.parent().membersInclude(this);
    });
  }

  orphanParents() {
    return uniq(compact(this.orphanSubgroups().map(group => group.parentId && group.parent())
    )
    );
  }

  membershipFor(group) {
    if (!group) { return; }
    return this.recordStore.memberships.find({groupId: group.id, userId: this.id})[0];
  }

  firstName() {
    if (this.name) { return head(this.name.split(' ')); }
  }

  saveVolume(volume, applyToAll) {
    this.processing = true;
    return this.remote.post('set_volume', {
      volume,
      apply_to_all: applyToAll,
      unsubscribe_token: this.unsubscribeToken
    }
    ).then(() => {
      if (!applyToAll) { return; }
      this.allThreads().forEach(thread => thread.update({discussionReaderVolume: null}));
      return this.memberships().forEach(membership => membership.update({volume}));
  }).finally(() => {
      return this.processing = false;
    });
  }

  hasExperienced(key, group) {
    if (group && this.isMemberOf(group)) {
      return this.membershipFor(group).experiences[key];
    } else {
      return this.experiences[key];
    }
  }

  title(group) {
    return this.titles[group.id] || this.titles[group.parentId];
  }

  nameWithTitle(group) {
    const name = this.nameOrEmail();
    if (!group) { return name; }
    const titles = this.titles || {};
    return compact([name, (titles[group.id] || titles[group.parentId])]).join(' · ');
  }
};
