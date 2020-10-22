import Records from '@/shared/services/records'
import { uniq, map, sortBy, head, find, debounce, filter, sum } from 'lodash'

export default
  data: ->
    recipients: []

  watch:
    query: ->
      @fetchMemberships()
      @updateSuggestions()

  methods:
    fetchMemberships: debounce ->
      return unless @query
      emails = uniq(@query.match(/[^\s:,;'"`<>]+?@[^\s:,;'"`<>]+\.[^\s:,;'"`<>]+/g) || [])
      return if emails.length

      @loading = true
      Records.memberships.fetch
        path: 'autocomplete'
        params:
          exclude_types: 'group'
          q: @query
          group_id: @outcome.group().parentOrSelf().groupId
          subgroups: 'all'
          per: 50
      .finally =>
        @loading = false
    , 300

    newQuery: (query) ->
      @query = query

  computed:
    notificationsCount: ->
      sum(@recipients.map((r) => r.size || 1))
