import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import GroupModel           from '@/shared/models/group_model'
import {uniq, concat, compact, map, includes} from 'lodash'
export default class GroupRecordsInterface extends BaseRecordsInterface
  model: GroupModel

  orphanSubgroups: (user) ->
    @view 'orphanSubgroups', (v) =>
      v.applyWhere (group) ->
        group.isSubgroup() && includes(@myGroups(), group)

  forUser: (user) ->
    @view "forUser(#{user.id})", (v) =>
      v.applyWhere (group) =>
        groupIds = map(@recordStore.memberships.forUser(user), 'groupId')
        includes(groupIds, group.id)

  formalGroupsForUser: (user) ->
    @view "formalGroupsForUser(#{user.id})", (v) =>
      v.applyWhere (group) => includes(@forUser(user), group)
      # v.applyFind({type: "FormalGroup"})
      v.applySimpleSort('fullName')

  sidebarGroups: (user) ->
    @view "sidebarGroups", (v) =>
      v.applyWhere (group) =>
        parentGroups = uniq compact map(@formalGroupsForUser(user), (group) -> group.parent())
        console.log 'formalGroupsForUser', @formalGroupsForUser(user)
        includes(concat(@formalGroupsForUser(user), parentGroups), group)
      v.applySimpleSort('fullName')

      # TODO: remove methods from user model if they are no longer used
      # orderedGroups: ->
      #   _sortBy @groups(), 'fullName'
      # groups: ->
      #   _filter Session.user().groups().concat(Session.user().orphanParents()), (group) =>
      #     group.type == "FormalGroup"
      #
      # groupIds: ->
      #   _.map(@memberships(), 'groupId')
      #
      # groups: ->
      #   groups = _.filter @recordStore.groups.find(id: { $in: @groupIds() }), (group) -> !group.isArchived()
      #   _.sortBy groups, 'fullName'
      #
      # orphanSubgroups: ->
      #   _.filter @groups(), (group) =>
      #     group.isSubgroup() and !@isMemberOf(group.parent())
      #
      # orphanParents: ->
      #   _.uniq _.map @orphanSubgroups(), (group) =>
      #     group.parent()

      # v.applyFind(modelId: $in: flatten([model.id, model.newDocumentIds]) )
      # v.applyFind(modelType: capitalize(model.constructor.singular))
      # v.applyWhere((doc) -> !includes model.removedDocumentIds, doc.id)
      # v.applySimpleSort('createdAt', true)

  fuzzyFind: (id) ->
    # could be id or key or handle
    @find(id) || _.head(@find(handle: id))

  findOrFetch: (id, options = {}, ensureComplete = false) ->
    record = @fuzzyFind(id)
    if record && (!ensureComplete || record.complete)
      Promise.resolve(record)
    else
      @remote.fetchById(id, options).then => @fuzzyFind(id)

  fetchByParent: (parentGroup) ->
    @fetch
      path: "#{parentGroup.id}/subgroups"

  fetchExploreGroups: (query, options = {}) ->
    options['q'] = query
    @fetch
      params: options

  getExploreResultsCount: (query, options = {}) ->
    options['q'] = query
    @fetch
      path: 'count_explore_results'
      params: options
