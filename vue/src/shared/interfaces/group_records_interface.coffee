import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import GroupModel           from '@/shared/models/group_model'
import Session              from '@/shared/services/session'
import EventBus             from '@/shared/services/event_bus'
import {uniq, concat, compact, map, includes} from 'lodash'
export default class GroupRecordsInterface extends BaseRecordsInterface
  model: GroupModel

  fuzzyFind: (id) ->
    # could be id or key or handle
    @find(id) || _.head(@find(handle: id))

  findOrFetch: (id, options = {}, ensureComplete = false) ->
    record = @fuzzyFind(id)
    if record && (!ensureComplete || record.complete)
      Promise.resolve(record)
    else
      @remote.fetchById(id, options).then => @fuzzyFind(id)

  findOrFetchOrAuthorize: (id, options = {}, ensureComplete = false) ->
    @findOrFetch(id, options, ensureComplete)
    .then (group) =>
      console.debug "found group, #{id} try saml #{@shouldTrySaml(id)}"
      @recordStore.samlProviders.authenticateForGroup(id) if @shouldTrySaml(id)
      group
    .catch (error) =>
      if error.status == 403 && @shouldTrySaml(id)
        console.debug "missing group, #{id} try saml #{@shouldTrySaml(id)}"
        @recordStore.samlProviders.authenticateForGroup(id)
        .then =>
          @fuzzyFind(id)
        .catch ->
          EventBus.$emit 'openAuthModal' if !Session.isSignedIn()
          throw error
      else
        throw error

  shouldTrySaml: (id) ->
    return false if Session.pendingInvitation()
    membership = Session.user().membershipFor(@fuzzyFind(id))

    console.debug
      id: id
      signed_in: Session.isSignedIn()
      membership: membership
      expired: membership.samlSessionExpired() if membership

    !Session.isSignedIn() || !membership || membership.samlSessionExpired()

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

  getHandle: ({name, parentHandle}) ->
    @fetch
      path: 'suggest_handle'
      params: {name: name, parent_handle: parentHandle}
