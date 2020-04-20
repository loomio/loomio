<script lang="coffee">
import AppConfig     from '@/shared/services/app_config'
import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import EventBus      from '@/shared/services/event_bus'
import ThreadFilter from '@/shared/services/thread_filter'
import GroupModalMixin from '@/mixins/group_modal.coffee'
import {each, keys, sum, values, sortBy} from 'lodash'

export default
  mixins: [ GroupModalMixin ]
  data: ->
    threadLimit: 50
    views: {}
    groups: []
    loading: false
    unreadCount: 0
    filters: [
      'only_threads_in_my_groups',
      'show_unread',
      'show_recent',
      'hide_muted',
      'hide_dismissed'
    ]

  created: ->
    @init()
    EventBus.$on 'signedIn', => @init()

  methods:
    startGroup: -> @openStartGroupModal()

    init: (options = {}) ->
      @loading = true
      Records.discussions.fetchInbox(options).then => @loading = false

      EventBus.$emit 'currentComponent',
        titleKey: 'inbox_page.unread_threads'
        page: 'inboxPage'

      @watchRecords
        collections: ['discussions', 'groups']
        query: (store) =>
          @groups = sortBy Session.user().inboxGroups(), 'name'
          @views = {}
          each @groups, (group) =>
            @views[group.key] = ThreadFilter(store, filters: @filters, group: group)
          @unreadCount = sum values(@views), (v) -> v.length

</script>

<template lang="pug">
v-content
  v-container.inbox-page.thread-preview-collection__container.max-width-1024(grid-list-lg)
    section.dashboard-page__loading(v-if='unreadCount == 0 && loading', aria-hidden='true')
      .thread-previews-container
        loading-content.thread-preview(:lineCount='2' v-for='(item, index) in [1,2,3,4,5,6,7,8,9,10]' :key='index')
    section.inbox-page__threads(v-if='unreadCount > 0 || !loading')
      .inbox-page__no-threads(v-show='unreadCount == 0')
        span(v-t="'inbox_page.no_threads'")
        span 🙌
      .inbox-page__no-groups(v-show='groups.length == 0')
        p(v-t="'inbox_page.no_groups.explanation'")
        button.lmo-btn-link--blue(v-t="'inbox_page.no_groups.start'", @click='startGroup()')
        | &nbsp;
        span(v-t="'inbox_page.no_groups.or'")
        | &nbsp;
        span(v-html="$t('inbox_page.no_groups.join_group')")
      .inbox-page__group(v-for='group in groups', :key='group.id')
        v-card.mb-3(v-if='views[group.key].length > 0')
          v-card-title
            v-avatar.mr-3(tile size="48px")
              v-img(:src='group.logoUrl()', aria-hidden='true')
            router-link.inbox-page__group-name(:to="'/g/' + group.key")
              span.subheading {{group.name}}
          thread-preview-collection(:threads="views[group.key]", :limit="threadLimit")
</template>
