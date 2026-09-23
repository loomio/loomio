import BaseRecordsInterface   from '@/shared/record_store/base_records_interface';
import MembershipRequestModel from '@/shared/models/membership_request_model';

export default class MembershipRequestRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = MembershipRequestModel;
    this.baseConstructor(recordStore);
  }

  fetchMineByGroup(groupKey, options) {
    if (options == null) { options = {}; }
    options['group_key'] = groupKey;
    return this.remote.get('mine', options);
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
    return this.remote.postMember(membershipRequest.id, 'approve', {
      group_key: membershipRequest.group().key
    });
  }

  decline(membershipRequest, declineReason) {
    return this.remote.postMember(membershipRequest.id, 'decline', {
      group_key: membershipRequest.group().key,
      membership_request: {decline_reason: declineReason}
    });
  }

  ignore(membershipRequest) {
    return this.remote.postMember(membershipRequest.id, 'ignore', {
      group_key: membershipRequest.group().key
    });
  }
};
