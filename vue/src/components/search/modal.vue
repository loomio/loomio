<script lang="coffee">
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import EventBus        from '@/shared/services/event_bus'
import Flash   from '@/shared/services/flash'
import Vue from 'vue'
import { debounce } from 'lodash'
import I18n from '@/i18n'

export default
  props:
    initialOrgId:
      required: false
      default: null
      type: Number
    initialGroupId:
      required: false
      default: null
      type: Number
    initialType:
      required: false
      default: null
      type: String

  created: ->
    @orgId = @initialOrgId
    @groupId = @initialGroupId
    @type = @initialType

  data: ->
    loading: false
    query: null
    results: []
    users: {}
    type: null
    typeItems: [
      {text: I18n.t('search_modal.all_content'), value: null},
      {text: I18n.t('group_page.threads'), value: 'Discussion'},
      {text: I18n.t('navbar.search.comments'), value: 'Comment'},
      {text: I18n.t('group_page.polls'), value: 'Poll'},
      {text: I18n.t('poll_common.votes'), value: 'Stance'},
      {text: I18n.t('poll_common.outcomes'), value: 'Outcome'},
    ]
    orgItems: [
      {text: I18n.t('sidebar.all_groups'), value: null},
      {text: I18n.t('sidebar.invite_only_threads'), value: 0}
    ].concat(Session.user().parentGroups().map (g) -> {text: g.name, value: g.id})
    orgId: null
    groupItems: []
    groupId: null
    order: null,
    orderItems: [
      {text: I18n.t('search_modal.best_match'), value: null},
      {text: I18n.t('strand_nav.newest'), value: "authored_at_desc"},
      {text: I18n.t('strand_nav.oldest'), value: "authored_at_asc"},
    ]
    tag: null,
    tagItems: []
    group: null

  methods:
    debounceFetch: debounce ->
      @fetch()
    , 300

    userById: (id) -> Records.users.find(id)
    pollById: (id) -> Records.polls.find(id)
    groupById: (id) -> Records.groups.find(id)

    fetch: ->
      if !@query
        @results = []
      else
        @loading = true
        Records.remote.get('search', query: @query, type: @type, org_id: @orgId, group_id: @groupId, order: @order, tag: @tag).then (data) =>
          @results = data.search_results
        .finally =>
          @loading = false

    urlForResult: (result) ->
      switch result.searchable_type
        when 'Discussion'
          "/d/#{result.discussion_key}/#{@stub(result.discussion_title)}"
        when 'Comment'
          "/d/#{result.discussion_key}/comment/#{result.searchable_id}"
        when 'Poll', 'Outcome', 'Stance'
          if result.sequence_id
            "/d/#{result.discussion_key}/#{@stub(result.discussion_title)}/#{result.sequence_id}"
          else
            "/p/#{result.poll_key}/#{@stub(result.poll_title)}"
        else
          '/notdefined'

    stub: (name) ->
      name.replace(/[^a-z0-9\-_]+/gi, '-').replace(/-+/g, '-').toLowerCase()

    closeModal: ->
      EventBus.$emit('closeModal')

    updateTagItems: (group) ->
      @tagItems = [{text: I18n.t('search_modal.any_tag'), value: null}].concat group.tagsByName().map (t) -> 
        {text: t.name, value: t.name}

  watch:
    orgId: (newval, oldval)->
      if @orgId
        @group = Records.groups.find(@orgId)
        base = [
          {text: I18n.t('search_modal.all_subgroups'), value: null},
          {text: I18n.t('search_modal.parent_only'), value: @orgId},
        ]
        @updateTagItems(@group)
        @groupItems = base.concat @group.subgroups().filter((g) -> !g.archivedAt && g.membershipFor(Session.user())).map (g) ->
          {text: g.name, value: g.id}
      else
        @groupItems = []
        @tagItems = []
      @fetch()

    groupId: (groupId) -> 
      if groupId
        group = Records.groups.find(groupId)
        @updateTagItems(group)
      @fetch()
    type: -> @fetch()
    order: -> @fetch()
    tag: -> @fetch()

    '$route.path': 'closeModal'

</script>
<template lang="pug">
v-card.search-modal
  .d-flex.px-4.pt-4.align-center
    v-text-field(:loading="loading" autofocus filled rounded single-line append-icon="mdi-magnify" append-outer-icon="mdi-close" @click:append-outer="closeModal" @click:append="fetch" v-model="query" :placeholder="$t('common.action.search')" @keydown.enter.prevent="fetch")
  .d-flex.px-4.align-center
    v-select.mr-2(v-model="orgId" :items="orgItems")
    v-select.mr-2(v-if="groupItems.length > 2" v-model="groupId" :items="groupItems" :disabled="!orgId")
    v-select.mr-2(v-if="tagItems.length" v-model="tag" :items="tagItems")
    v-select.mr-2(v-model="type" :items="typeItems")
    v-select(v-model="order" :items="orderItems")
  v-list(two-line)
    v-list-item.poll-common-preview(v-for="result in results" :key="result.id" :to="urlForResult(result)")
      v-list-item-avatar 
        poll-common-icon-panel(v-if="['Outcome', 'Poll'].includes(result.searchable_type)" :poll='pollById(result.poll_id)' show-my-stance)
        user-avatar(v-else :user="userById(result.author_id)")
      v-list-item-content
        v-list-item-title.d-flex
          span.text-truncate {{ result.poll_title || result.discussion_title }}
          tags-display(:tags="result.tags" :group="groupById(result.group_id)" smaller)
          v-spacer
          time-ago.text--secondary(style="font-size: 0.875rem;" :date="result.authored_at")
        v-list-item-subtitle.text--primary(v-html="result.highlight")
        v-list-item-subtitle
          span
            span {{result.searchable_type}}
            mid-dot
            span {{result.author_name}}
            mid-dot
            span {{result.group_name || $t('discussion.invite_only')}}

</template>
