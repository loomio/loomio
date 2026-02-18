import BaseModel from '@/shared/record_store/base_model';
import AppConfig from '@/shared/services/app_config';
import { find, filter, flatten, uniq, head, compact, map, truncate  } from 'lodash-es';

import Records from '@/shared/services/records';

export default class UserModel extends BaseModel {
  static singular = 'user';
  static plural = 'users';
  static uniqueIndices = ['id'];

  relationships() {
    return this.hasMany('memberships');
  }

  defaultValues() {
    return {
      autodetectTimeZone: false,
      shortBio: '',
      shortBioFormat: 'html',
      files: null,
      imageFiles: null,
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
    return Records.memberships.find({userId: this.id, admin: true});
  }

  groupIds() {
    return map(this.memberships(), 'groupId');
  }

  groups() {
    return Records.groups.collection.chain().
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
    return uniq(compact(this.orphanSubgroups().map(group => group.parentId && group.parent())));
  }

  membershipFor(group) {
    if (!group) { return; }
    return Records.memberships.find({groupId: group.id, userId: this.id})[0];
  }

  firstName() {
    if (this.name) { return head(this.name.split(' ')); }
  }

  saveVolume(emailVolume, pushVolume, applyToAll) {
    this.processing = true;
    const payload = { apply_to_all: applyToAll, unsubscribe_token: this.unsubscribeToken };
    if (emailVolume != null) { payload.email_volume = emailVolume; }
    if (pushVolume != null) { payload.push_volume = pushVolume; }
    return Records[this.constructor.plural].remote.post('set_volume', payload).then(() => {
      if (!applyToAll) { return; }
      const threadUpdate = {};
      const membershipUpdate = {};
      if (emailVolume != null) { threadUpdate.discussionReaderEmailVolume = null; membershipUpdate.emailVolume = emailVolume; }
      if (pushVolume != null) { threadUpdate.discussionReaderPushVolume = null; membershipUpdate.pushVolume = pushVolume; }
      this.allThreads().forEach(thread => thread.update(threadUpdate));
      return this.memberships().forEach(membership => membership.update(membershipUpdate));
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
