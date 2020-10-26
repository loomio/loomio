import Records from '@/shared/services/records'
import { uniq, map, sortBy, head, find, debounce, filter, sum } from 'lodash'
import Session from '@/shared/services/session'

export default
  data: ->
    recipients: []
    users: []
    query: ''
    groups: []
    users: []

  watch:
    query: ->
      @fetchMemberships()
      @updateSuggestions()

  methods:
    updateSuggestions: ->
      @users = @findUsers()
      @groups = @findGroups()

    fetchMembershipsParams: -> {}
    findGroups: -> []

    excludedUserIds: ->
      [Session.user().id]

    findUsers: ->
      chain = Records.users.collection.chain()

      if @model.groupId
        chain = chain.find(id: {$in: @model.group().parentAndSelfMemberIds()})

      chain = chain.find(id: {$nin: @excludedUserIds()})

      if @query
        chain = chain.find
          $or: [
            {name: {'$regex': ["^#{@query}", "i"]}}
            {username: {'$regex': ["^#{@query}", "i"]}}
            {name: {'$regex': [" #{@query}", "i"]}}
          ]

      chain.data()

    fetchMemberships: debounce ->
      if @query
        emails = uniq(@query.match(/[^\s:,;'"`<>]+?@[^\s:,;'"`<>]+\.[^\s:,;'"`<>]+/g) || [])
        return if emails.length

      @loading = true

      params = Object.assign
        exclude_types: 'group'
        q: @query
        subgroups: 'all'
        per: 20
      ,
        @fetchMembershipsParams()

      Records.memberships.fetch
        path: 'autocomplete'
        params: params
      .finally =>
        @loading = false
    , 300

    newQuery: (query) ->
      @query = query

  computed:
    notificationsCount: ->
      sum(@recipients.map((r) => r.size || 1))
