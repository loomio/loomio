import BaseModel    from '@/shared/record_store/base_model';
import AppConfig    from '@/shared/services/app_config';
import HasDocuments from '@/shared/mixins/has_documents';
import HasTranslations  from '@/shared/mixins/has_translations';
import {filter, some, map, each, compact} from 'lodash-es';

export default class GroupModel extends BaseModel {
  static singular = 'group';
  static plural = 'groups';
  static uniqueIndices = ['id', 'key'];
  static indices = ['parentId'];

  constructor(...args) {
    super(...args);
    this.archive = this.archive.bind(this);
    this.export = this.export.bind(this);
    this.exportCSV = this.exportCSV.bind(this);
    this.uploadLogo = this.uploadLogo.bind(this);
    this.uploadCover = this.uploadCover.bind(this);
  }

  defaultValues() {
    return {
      parentId: null,
      name: '',
      description: '',
      descriptionFormat: 'html',
      groupPrivacy: 'secret',
      handle: null,
      discussionPrivacyOptions: 'private_only',
      membershipGrantedUpon: 'approval',
      membersCanAnnounce: true,
      membersCanAddMembers: true,
      membersCanEditDiscussions: true,
      membersCanEditComments: true,
      membersCanDeleteComments: true,
      membersCanRaiseMotions: true,
      membersCanStartDiscussions: true,
      membersCanCreateSubgroups: false,
      motionsCanBeEdited: false,
      parentMembersCanSeeDiscussions: false,
      category: null,
      files: [],
      imageFiles: [],
      attachments: [],
      linkPreviews: [],
      subscription: {},
      specifiedVotersOnly: false,
      recipientMessage: null,
      recipientAudience: null,
      recipientUserIds: [],
      recipientChatbotIds: [],
      recipientEmails: [],
      notifyRecipients: true,
      isMember: false,
      isAdmin: false
    };
  }

  afterConstruction() {
    if (this.privacyIsClosed()) {
      this.allowPublicThreads = this.discussionPrivacyOptions === 'public_or_private';
    }
    HasDocuments.apply(this, {showTitle: true});
    return HasTranslations.apply(this);
  }

  relationships() {
    this.hasMany('discussions', {find: {discardedAt: null}});
    this.hasMany('polls', {find: {discardedAt: null}});
    this.hasMany('membershipRequests');
    this.hasMany('memberships');
    this.hasMany('chatbots');
    this.hasMany('allDocuments', {from: 'documents', with: 'groupId', of: 'id'});
    this.hasMany('subgroups', {from: 'groups', with: 'parentId', of: 'id', orderBy: 'name'});
    this.belongsTo('parent', {from: 'groups'});
    return this.belongsTo('creator', {from: 'users'});
  }

  author() { return this.creator(); }

  isBlank() {
    return (this.description === '') || (this.description === null) || (this.description === '<p></p>');
  }

  tags() {
    return this.recordStore.tags.collection.chain().find({groupId: this.id}).simplesort('priority').data();
  }

  tagsByName() {
    return this.recordStore.tags.collection.chain().find({groupId: this.id}).simplesort('name').data();
  }

  tagNames() {
    return this.recordStore.tags.collection.chain().find({groupId: this.id}).simplesort('name').data().map(t => t.name);
  }

  parentOrSelf() {
    if (this.parentId) { return this.parent(); } else { return this; }
  }

  group() { return this; }

  fetchToken() {
    return this.remote.getMember(this.id, 'token')
    .then(() => this.token);
  }

  resetToken() {
    return this.remote.postMember(this.id, 'reset_token')
    .then(() => this.token);
  }

  pendingMembershipRequests() {
    return filter(this.membershipRequests(), membershipRequest => membershipRequest.isPending());
  }

  hasPendingMembershipRequests() {
    return some(this.pendingMembershipRequests());
  }

  hasPendingMembershipRequestFrom(user) {
    return some(this.pendingMembershipRequests(), request => request.requestorId === user.id);
  }

  previousMembershipRequests() {
    return filter(this.membershipRequests(), membershipRequest => !membershipRequest.isPending());
  }

  hasPreviousMembershipRequests() {
    return some(this.previousMembershipRequests());
  }

  pendingInvitations() {
    return filter(this.invitations(), invitation => invitation.isPending() && invitation.singleUse);
  }

  hasPendingInvitations() {
    return some(this.pendingInvitations());
  }

  hasSubgroups() {
    return this.isParent() && this.subgroups().length;
  }

  publicOrganisationIds() {
    return map(filter(this.subgroups().concat(this), group => group.groupPrivacy === 'open'), 'id');
  }

  organisationIds() {
    return map(this.subgroups(), 'id').concat(this.id);
  }

  selfAndSubgroups() {
    return this.recordStore.groups.find(this.selfAndSubgroupIds());
  }

  selfAndSubgroupIds() {
    return [this.id].concat(this.recordStore.groups.find({parentId: this.id}).map(g => g.id));
  }

  membershipFor(user) {
    return this.recordStore.memberships.find({groupId: this.id, userId: user.id})[0];
  }

  members() {
    return this.recordStore.users.collection.find({id: {$in: this.memberIds()}});
  }

  parentsAndSelf() {
    return this.selfAndParents().reverse();
  }

  selfAndParents() {
    return compact([this].concat(this.parentId && this.parent().parentsAndSelf()));
  }

  parentAndSelfMemberships() {
    return this.recordStore.memberships.collection.find({groupId: {$in: this.parentOrSelf().selfAndSubgroupIds()}});
  }

  parentAndSelfMembershipIds() {
    return this.parentAndSelfMemberships().map(u => u.id);
  }

  parentAndSelfMembers() {
    return this.recordStore.users.collection.find({id: {$in: this.parentAndSelfMemberships().map(m => m.userId)}});
  }

  parentAndSelfMemberIds() {
    return this.parentAndSelfMembers().map(u => u.id);
  }

  membersInclude(user) {
    return this.membershipFor(user) || false;
  }

  adminsInclude(user) {
    return this.recordStore.memberships.find({groupId: this.id, userId: user.id, admin: true})[0] || false;
  }

  adminMemberships() {
    return this.recordStore.memberships.find({groupId: this.id, admin: true});
  }

  admins() {
    return this.recordStore.users.find({id: {$in: this.adminIds()}});
  }

  memberIds() {
    return map(this.memberships(), 'userId');
  }

  participantIds() {
    return this.memberIds();
  }

  adminIds() {
    return map(this.adminMemberships(), 'userId');
  }

  parentName() {
    if (this.parent() != null) { return this.parent().name; }
  }

  privacyIsOpen() {
    return this.groupPrivacy === 'open';
  }

  privacyIsClosed() {
    return this.groupPrivacy === 'closed';
  }

  privacyIsSecret() {
    return this.groupPrivacy === 'secret';
  }

  isArchived() {
    return (this.archivedAt != null);
  }

  isParent() {
    return (this.parentId == null);
  }

  archive() {
    return this.remote.patchMember(this.key, 'archive').then(() => {
      this.remove();
      return each(this.memberships(), m => m.remove());
    });
  }

  export() {
    return this.remote.postMember(this.id, 'export');
  }

  exportCSV() {
    return this.remote.postMember(this.id, 'export_csv');
  }

  uploadLogo(file) {
    return this.remote.upload(`${this.key}/upload_photo/logo`, file, {}, function() {});
  }

  uploadCover(file) {
    return this.remote.upload(`${this.key}/upload_photo/cover_photo`, file, {}, function() {});
  }

  hasSubscription() {
    return (this.subscriptionKind != null);
  }

  isSubgroupOfSecretParent() {
    return this.parent() && this.parent().privacyIsSecret();
  }
};
