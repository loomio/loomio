/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let NullGroupModel;
import {each} from 'lodash';
import Vue from 'vue';
import I18n from '@/i18n';

export default NullGroupModel = (function() {
  NullGroupModel = class NullGroupModel {
    static initClass() {
      this.singular = 'group';
      this.plural = 'groups';
      this.prototype.subscription = {};
    }

    constructor() {
      const defaults = {
        parentId: null,
        name: I18n.t('discussion.invite_only'),
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
        files: [],
        imageFiles: [],
        attachments: [],
        linkPreviews: [],
        subscription: {active: true},
        specifiedVotersOnly: false,
        isNullGroup: true,
        categorizePollTemplates: true
      };

      each(defaults, (value, key) => {
        Vue.set(this, key, value);
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
  NullGroupModel.initClass();
  return NullGroupModel;
})();
