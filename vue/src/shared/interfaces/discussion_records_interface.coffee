import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import DiscussionModel      from '@/shared/models/discussion_model'
import Session              from '@/shared/services/session'
import EventBus             from '@/shared/services/event_bus'
import { includes } from 'lodash'

export default class DiscussionRecordsInterface extends BaseRecordsInterface
  model: DiscussionModel

  findOrFetchOrAuthorize: (id, options = {}, ensureComplete = false) ->
    @findOrFetchById(id, options, ensureComplete)
    .then (discussion) =>
      @recordStore.samlProviders.authenticateForDiscussion(id) if @shouldTrySaml(id)
      discussion
    .catch (error) =>
      @recordStore.samlProviders.authenticateForDiscussion(id)
      .then =>
        @find(id)
      .catch ->
        EventBus.$emit 'openAuthModal' if error.status == 403
        throw error
      # this doesnt work because we never got the discussion record in the unhappy path
      # if @shouldTrySaml(id)
      #   @recordStore.samlProviders.authenticateForDiscussion(id)
      #   .then =>
      #     @find(id)
      #   .catch ->
      #     EventBus.$emit 'openAuthModal' if error.status == 403
      # else
      #   throw error

  shouldTrySaml: (id) ->
    discussion = @find(id)
    !Session.pendingInvitation() && (!Session.isSignedIn() || !Session.user().membershipFor(discussion.group()))

  fetchHistoryFor: (discussion) ->
    params = discussion.id

    @remote.fetch
      path: discussion.id + '/history'
      params: params

  search: (groupKey, fragment, options = {}) ->
    options.group_id = groupKey
    options.q = fragment
    @fetch
      path: 'search'
      params: options

  fetchByGroup: (groupKey, options = {}) ->
    options['group_id'] = groupKey
    @fetch
      params: options

  fetchDashboard: (options = {}) ->
    @fetch
      path: 'dashboard'
      params: options

  fetchInbox: (options = {}) ->
    @fetch
      path: 'inbox'
      params:
        from: options['from'] or 0
        per: options['per'] or 100
        # since: options['since'] or moment().startOf('day').subtract(6, 'week').toDate()
        # timeframe_for: options['timeframe_for'] or 'last_activity_at'
