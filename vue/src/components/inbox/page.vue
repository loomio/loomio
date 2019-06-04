<style lang="scss">
@import 'mixins';
@import 'lmo_card';

.inbox-page .thread-preview__pin {
  display: none;
}
</style>

<script lang="coffee">
import AppConfig     from '@/shared/services/app_config'
import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import EventBus      from '@/shared/services/event_bus'
import ThreadFilter from '@/shared/services/thread_filter'
import ModalService  from '@/shared/services/modal_service'
import urlFor        from '@/mixins/url_for'
import {each, keys, sum, values, sortBy} from 'lodash'
import WatchRecords from '@/mixins/watch_records'

export default
  mixins: [urlFor, WatchRecords]
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
    startGroup: ->
      ModalService.open 'GroupModal', group: => Records.groups.build()

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


    query: ->
      ThreadQueryService.queryFor(name: "inbox", filters: @filters)

</script>

<template lang="pug">
v-container.lmo-main-container.inbox-page(grid-list-lg)
  .thread-preview-collection__container
    h1.lmo-h1-medium.inbox-page__heading(v-t="'inbox_page.unread_threads'")
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
        span(v-t="'inbox_page.no_groups.or'")
        span(v-t="'inbox_page.no_groups.join_group'")
      .inbox-page__group(v-for='group in groups', :key='group.id')
        v-card.mb-3(v-if='views[group.key].length > 0')
          v-card-title
            v-avatar.mr-2(tile size="48px")
              v-img(:src='group.logoUrl()', aria-hidden='true')
            router-link.inbox-page__group-name(:to="'/g/' + group.key")
              span.subheading {{group.name}}
          thread-preview-collection(:threads="views[group.key]", :limit="threadLimit")
</template>
