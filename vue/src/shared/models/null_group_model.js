import {each} from 'lodash-es';
import { I18n } from '@/i18n';

export default class NullGroupModel {
  static singular = 'group';
  static plural = 'groups';
  static subscription = {};

  constructor() {
    const defaults = {
      parentId: null,
      name: I18n.global.t('discussion.invite_only'),
      description: '',
      descriptionFormat: 'html',
      groupPrivacy: 'closed',
      handle: null,
      discussionPrivacyOptions: 'public_or_private',
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
      files: null,
      imageFiles: null,
      attachments: [],
      linkPreviews: [],
      subscription: {active: true},
      specifiedVotersOnly: false,
      isNullGroup: true,
      categorizePollTemplates: true
    };

    each(defaults, (value, key) => {
      this[key] = value;
      return true;
    });
  }

  chatbots() { return []; }
  poll() { return []; }
  discussions() { return []; }
  memberships() { return []; }
  membershipRequests() { return []; }
  subgroups() { return []; }
  parent() { return null; }
  parentOrSelf() { return this; }
  parentsAndSelf() { return [this]; }
  selfAndSubgroups() { return [this]; }
  group() { return this; }
  hasSubgroups() { return false; }
  tags() { return []; }
  organisationIds() { return []; }
  membershipFor() { return null; }
  members() { return []; }
  membersInclude() { return false; }
  adminsInclude() { return false; }
  adminMemberships() { return []; }
  admins() { return []; }
  memberIds() { return []; }
  adminIds() { return []; }
  parentName() { return null; }
  privacyIsOpen() { return false; }
  privacyIsClosed() { return false; }
  privacyIsSecret() { return true; }
  isArchived() { return false; }
  isParent() { return true; }
  hasSubscription() { return false; }
  isSubgroupOfSecretParent() { return false; }
  hasPendingMembershipRequestFrom() { return false; }
};
