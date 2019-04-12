import BaseRecordsInterface   from '@/shared/record_store/base_records_interface'
import MembershipRequestModel from '@/shared/models/membership_request_model'

export default class MembershipRequestRecordsInterface extends BaseRecordsInterface
  model: MembershipRequestModel

  fetchMyPendingByGroup: (groupKey, options = {}) ->
    options['group_key'] = groupKey
    @remote.get('/my_pending', options)

  fetchPendingByGroup: (groupKey, options = {}) ->
    options['group_key'] = groupKey
    @remote.get('/pending', options)

  fetchPreviousByGroup: (groupKey, options = {}) ->
    options['group_key'] = groupKey
    @remote.get('/previous', options)

  approve: (membershipRequest) ->
    @remote.postMember(membershipRequest.id, 'approve', group_key: membershipRequest.group().key)

  ignore: (membershipRequest) ->
    @remote.postMember(membershipRequest.id, 'ignore', group_key: membershipRequest.group().key)
