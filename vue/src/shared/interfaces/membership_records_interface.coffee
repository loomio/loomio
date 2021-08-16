import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import MemberhipModel       from '@/shared/models/membership_model'
import {includes} from 'lodash'

export default class MemberhipRecordsInterface extends BaseRecordsInterface
  model: MemberhipModel

  forUser: (user) ->
    @collection.find(userId: user.id)

  forModel: (model) ->
    @collection.find(groupId: {$in: model.groupIds()})

  forGroup: (group) ->
    @collection.find(groupId: group.id)

  joinGroup: (group) ->
    @remote.post 'join_group', group_id: group.id
    .then (data) => @recordStore.importJSON(data)

  fetchMyMemberships: ->
    @fetch
      path: 'my_memberships'

  # There's a pattern emerging for searching by fragment...
  fetchByNameFragment: (fragment, groupKey, limit = 5) ->
    @fetch
      path: 'autocomplete'
      params: { q: fragment, group_key: groupKey, per: limit }

  # fetchByGroup: (groupKey, options = {}) ->
  #   @fetch
  #     params:
  #       group_key: groupKey
  #       per: options['per'] or 30

  fetchByUser: (user, options = {}) ->
    @fetch
      path: 'for_user'
      params:
        user_id: user.id
        per: options['per'] or 30

  makeAdmin: (membership) ->
    @remote.postMember membership.id, "make_admin"
    .then (data) => @recordStore.importJSON(data)

  removeAdmin: (membership) ->
    @remote.postMember membership.id, "remove_admin"
    .then (data) => @recordStore.importJSON(data)

  saveExperience: (experience, membership) =>
    @remote.postMember(membership.id, "save_experience", experience: experience)
    .then (data) => @recordStore.importJSON(data)
