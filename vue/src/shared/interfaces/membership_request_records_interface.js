import BaseRecordsInterface   from '@/shared/record_store/base_records_interface';
import MembershipRequestModel from '@/shared/models/membership_request_model';

export default class MembershipRequestRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = MembershipRequestModel;
    this.baseConstructor(recordStore);
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
