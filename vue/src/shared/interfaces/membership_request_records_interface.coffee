import BaseRecordsInterface   from '@/shared/record_store/base_records_interface'
import MembershipRequestModel from '@/shared/models/membership_request_model'

export default class MembershipRequestRecordsInterface extends BaseRecordsInterface
  model: MembershipRequestModel

  fetchMyPendingByGroup: (groupKey, options = {}) ->
    options['group_key'] = groupKey
    @remote.get('my_pending', options).then (data) => @recordStore.importJSON(data)

  fetchPendingByGroup: (groupKey, options = {}) ->
    options['group_key'] = groupKey
    @remote.get('pending', options).then (data) => @recordStore.importJSON(data)

  fetchPreviousByGroup: (groupKey, options = {}) ->
    options['group_key'] = groupKey
    @remote.get('previous', options).then (data) => @recordStore.importJSON(data)

  approve: (membershipRequest) ->
    @remote.postMember(membershipRequest.id, 'approve', group_key: membershipRequest.group().key)
    .then (data) => @recordStore.importJSON(data)

  ignore: (membershipRequest) ->
    @remote.postMember(membershipRequest.id, 'ignore', group_key: membershipRequest.group().key)
    .then (data) => @recordStore.importJSON(data)
