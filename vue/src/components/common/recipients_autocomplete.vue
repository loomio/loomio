<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import {map, debounce, without, filter, uniq, uniqBy} from 'lodash'
import RecipientsNotificationsCount from '@/components/common/recipients_notifications_count'

export default
  components: {
    RecipientsNotificationsCount
  }

  props:
    autofocus: Boolean
    label: String
    placeholder: String
    reset: Boolean
    initialRecipients:
      type: Array
      default: -> []
    groups:
      type: Array
      default: -> []
    users:
      type: Array
      default: -> []

  data: ->
    query: null
    searchResults: []
    recipients: @initialRecipients
    emailAddresses: []
    loading: false

  watch:

    reset: ->
      @query = ''
      @recipients = @initialRecipients
      @emailAddresses = []
      @updateSearchResults()

    groups: ->
      @updateSearchResults()

    recipients: (val) ->
      @$emit('new-recipients', val)

    query: (q) ->
      @$emit('new-query', q)
      @findEmailAddresses(q)
      @updateSearchResults()

  methods:
    findEmailAddresses: ->
      return unless @query

      @emailAddresses = uniq(@query.match(/[^\s:,;'"`<>]+?@[^\s:,;'"`<>]+\.[^\s:,;'"`<>]+/g) || [])

      # catch paste of multiple email addresses, or failure to press enter after an email address
      if @emailAddresses.length > 1 or (@emailAddresses.length == 1 && [',', ' '].includes(@query.slice(-1)))
        objs = uniqBy @recipients.concat(@emailAddresses.map((e) -> {id: e, type: 'email', name: e})), 'id'
        @recipients = objs
        @searchResults = objs
        @query = ''
        @emailAddresses = []
        return

    remove: (item) ->
      @recipients = filter @recipients, (r) ->
        !(r.id == item.id && r.type == item.type)

    updateSearchResults: ->
      if @emailAddresses.length
        @searchResults = @recipients.concat @emailAddresses.map (e) ->
          id: e
          type: 'email'
          name: e
        return

      members = @users.map (u) ->
        id: u.id
        type: 'user'
        name: u.name
        user: u

      groups = @groups.map (g) ->
        id: g.id
        type: 'group'
        name: g.name
        group: g

      @searchResults = @recipients.concat(groups).concat(members)


</script>

<template lang="pug">
div
  v-autocomplete(
    :autofocus="autofocus"
    multiple
    chips
    return-object
    auto-select-first
    hide-no-data
    hide-selected
    v-model='recipients'
    @change="query= null"
    :search-input.sync="query"
    item-text='name'
    :loading="loading"
    :label="label"
    :placeholder="placeholder"
    :items='searchResults')
    template(v-slot:selection='data')
      v-chip.chip--select-multi(:value='data.selected' close @click:close='remove(data.item)')
        v-icon.mr-1(v-if="data.item.type == 'email'" small) mdi-email-outline
        v-icon.mr-1(v-if="data.item.type == 'group'" small) mdi-account-group
        user-avatar.mr-1(v-if="data.item.type == 'user'" :user="data.item.user" size="small" no-link)
        span {{ data.item.name }}
    template(v-slot:item='data')
      v-list-item-avatar
        v-icon(v-if="data.item.type == 'email'" small) mdi-email-outline
        v-icon.mr-1(v-if="data.item.type == 'group'" small) mdi-account-group
        user-avatar(v-if="data.item.type == 'user'" :user="data.item.user" size="small" no-link)
      v-list-item-content.announcement-chip__content
        v-list-item-title(v-html='data.item.name')
  recipients-notifications-count(:recipients="recipients")
</template>
