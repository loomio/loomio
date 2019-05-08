import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import MemberhipModel       from '@/shared/models/membership_model'
import {includes} from 'lodash'

export default class MemberhipRecordsInterface extends BaseRecordsInterface
  model: MemberhipModel

  forUser: (user) ->
    @view "membershipsFor(#{user.id})", (v) ->
      v.applyFind(userId: user.id)

  forModel: (model) ->
    @view "membershipsForModel(#{model.constructor.singular}, #{model.id})", (v) ->
      v.applyWhere (membership) =>
        includes(model.groupIds(), membership.groupId)

  joinGroup: (group) ->
    @remote.post 'join_group', group_id: group.id

  fetchMyMemberships: ->
    @fetch
      path: 'my_memberships'

  # There's a pattern emerging for searching by fragment...
  fetchByNameFragment: (fragment, groupKey, limit = 5) ->
    @fetch
      path: 'autocomplete'
      params: { q: fragment, group_key: groupKey, per: limit }

  fetchInvitables: (fragment, groupKey, limit = 5) ->
    @fetch
      path: 'invitables'
      params: { q: fragment, group_key: groupKey, per: limit }

  fetchByGroup: (groupKey, options = {}) ->
    @fetch
      params:
        group_key: groupKey
        per: options['per'] or 30

  fetchByUser: (user, options = {}) ->
    @fetch
      path: 'for_user'
      params:
        user_id: user.id
        per: options['per'] or 30

  addUsersToSubgroup: ({groupId, userIds}) ->
    @remote.post 'add_to_subgroup',
      group_id: groupId
      user_ids: userIds

  makeAdmin: (membership) ->
    @remote.postMember membership.id, "make_admin"

  removeAdmin: (membership) ->
    @remote.postMember membership.id, "remove_admin"

  saveExperience: (experience, membership) =>
    @remote.postMember(membership.id, "save_experience", experience: experience)
