<script lang="coffee">
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import EventBus        from '@/shared/services/event_bus'
import Flash   from '@/shared/services/flash'
import Vue from 'vue'
import { debounce } from 'lodash'

export default
  props:
    group: Object
    discussion: Object

  data: ->
    query: null
    results: []
    users: {}
    queryTypes: ['Discussion', 'Comment', 'Poll', 'Stance', 'Outcome']
    orgIds: [
      {text: 'Everywhere', value: null}
    ].concat(Session.user().parentGroups().map (g) -> {text: g.name, value: g.id})
    orgId: null
    typeMenu: false

  methods:
    debounceFetch: debounce ->
      @fetch()
    , 300

    fetch: ->
      Records.remote.get('search', query: @query, query_types: @queryTypes.join('-'), org_id: @orgId).then (data) =>
        data.map((row) -> row.author_id).forEach (id) =>
          if user = Records.users.find(id)
            Vue.set @users, id, user
          else
            Records.users.addMissing(id)
        @results = data

    urlForResult: (result) ->
      switch result.searchable_type
        when 'Discussion'
          "/d/#{result.discussion_key}/#{@stub(result.discussion_title)}"
        when 'Comment'
          "/d/#{result.discussion_key}/comment/#{result.searchable_id}"
        when 'Poll'
          "/p/#{result.poll_key}/#{@stub(result.poll_title)}"
        when 'Outcome'
          "/p/#{result.poll_key}/#{@stub(result.poll_title)}"
        when 'Stance'
          "/p/#{result.poll_key}/#{@stub(result.poll_title)}"
        else
          '/notdefined'

    stub: (name) ->
      name.replace(/[^a-z0-9\-_]+/gi, '-').replace(/-+/g, '-').toLowerCase()

    closeModal: ->
      EventBus.$emit 'closeModal'

  watch:
    query: 'debounceFetch'
    orgId: 'debounceFetch'
    queryTypes: 'debounceFetch'
    '$route.path': 'closeModal'

</script>
<template lang="pug">
v-card.search-modal
  dismiss-modal-button
  .d-flex.px-4
    v-text-field(autofocus filled rounded single-line v-model="query" placeholder="search for something", @change="fetch")
  .d-flex.px-4.align-center
    v-select(v-model="orgId" :items="orgIds")
    v-spacer
    v-menu(
      v-model="typeMenu"
      :close-on-content-click="false"
      :nudge-width="200"
      offset-x)
      template(v-slot:activator="{ on, attrs }")
        v-btn(color="indigo"
          dark
          v-bind="attrs"
          v-on="on") Types ({{queryTypes.length}})
      v-card
        v-list
          v-list-item 
            v-list-item-action 
              v-checkbox(v-model="queryTypes" value="Discussion")
            v-list-item-title Threads
          v-list-item 
            v-list-item-action 
              v-checkbox(v-model="queryTypes" value="Comment")
            v-list-item-title Comments
          v-list-item
            v-list-item-action 
              v-checkbox(v-model="queryTypes" value="Poll")
            v-list-item-title Polls
          v-list-item
            v-list-item-action 
              v-checkbox(v-model="queryTypes" value="Stance")
            v-list-item-title Votes
          v-list-item
            v-list-item-action 
              v-checkbox(v-model="queryTypes" value="Outcome")
            v-list-item-title Outcomes

  v-list(two-line)
    v-list-item(v-for="result in results" :key="result.id" :to="urlForResult(result)")
      v-list-item-avatar 
        user-avatar(:user="users[result.author_id]")
      v-list-item-content
        v-list-item-title [{{result.group_name}}] {{result.discussion_title || result.poll_title}}
        v-list-item-subtitle(v-html="result.highlight")


</template>
