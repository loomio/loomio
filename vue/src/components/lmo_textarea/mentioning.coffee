import {sortBy, isString, filter, uniq, map} from 'lodash'
import Records from '@/shared/services/records'

export default
  methods:
    fetchMentionable: ->
      Records.users.fetchMentionable(@query, @model).then (response) =>
        @mentionableUserIds.concat(uniq @mentionableUserIds + map(response.users, 'id'))

  computed:
    filteredUsers: ->
      unsorted = filter Records.users.collection.chain().find(@mentionableUserIds).data(), (u) =>
        isString(u.username) &&
        ((u.name || '').toLowerCase().startsWith(@query) or
        (u.username || '').toLowerCase().startsWith(@query) or
        (u.name || '').toLowerCase().includes(" #{@query}"))
      sortBy(unsorted, (u) -> (0 - Records.events.find(actorId: u.id).length))
