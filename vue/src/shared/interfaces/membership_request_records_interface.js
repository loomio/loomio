/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let MembershipRequestRecordsInterface;
import BaseRecordsInterface   from '@/shared/record_store/base_records_interface';
import MembershipRequestModel from '@/shared/models/membership_request_model';

export default MembershipRequestRecordsInterface = (function() {
  MembershipRequestRecordsInterface = class MembershipRequestRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = MembershipRequestModel;
    }

    fetchMyPendingByGroup(groupKey, options) {
      if (options == null) { options = {}; }
      options['group_key'] = groupKey;
      return this.remote.get('my_pending', options);
    }

    fetchPendingByGroup(groupKey, options) {
      if (options == null) { options = {}; }
      options['group_key'] = groupKey;
      return this.remote.get('pending', options);
    }

    fetchPreviousByGroup(groupKey, options) {
      if (options == null) { options = {}; }
      options['group_key'] = groupKey;
      return this.remote.get('previous', options);
    }

    approve(membershipRequest) {
      return this.remote.postMember(membershipRequest.id, 'approve', {group_key: membershipRequest.group().key});
    }

    ignore(membershipRequest) {
      return this.remote.postMember(membershipRequest.id, 'ignore', {group_key: membershipRequest.group().key});
    }
  };
  MembershipRequestRecordsInterface.initClass();
  return MembershipRequestRecordsInterface;
})();
