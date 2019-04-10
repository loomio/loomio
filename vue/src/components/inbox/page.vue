<style lang="scss">
@import 'mixins';
@import 'lmo_card';

.inbox-page .thread-preview__pin {
  display: none;
}
</style>

<script lang="coffee">
AppConfig      = require 'shared/services/app_config'
Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
InboxService   = require 'shared/services/inbox_service'
ModalService   = require 'shared/services/modal_service'
urlFor         = require 'src/mixins/url_for'

# import ThreadPreviewCollection from 'src/components/thread/preview_collection.vue'

module.exports =
  mixins: [urlFor]
  data: ->
    threadLimit: 50
    views: InboxService.queryByGroup()
  created: ->
    EventBus.$emit 'currentComponent',
      titleKey: 'inbox_page.unread_threads'
      page: 'inboxPage'
    InboxService.load()
  methods:
    startGroup: ->
      ModalService.open 'GroupModal', group: => Records.groups.build()
  computed:
    loading: ->
      !InboxService.loaded

    groups: ->
      Records.groups.find(_.keys(@views))

    hasThreads: ->
      InboxService.unreadCount() > 0

    noGroups: ->
      !Session.user().hasAnyGroups()

    orderedGroups: ->
      _.sortBy @groups, 'name'
</script>

<template lang="pug">
v-container.lmo-main-container.inbox-page(grid-list-lg)
  .thread-preview-collection__container
    //- h1.lmo-h1-medium.inbox-page__heading(v-t="'inbox_page.unread_threads'")
    section.dashboard-page__loading(v-if='loading', aria-hidden='true')
      .thread-previews-container
        // <loading_content line-count="2" ng-repeat="i in [1,2,3,4,5,6,7,8,9,10] track by $index" class="thread-preview"></loading_content>
    section.inbox-page__threads(v-if='!loading')
      .inbox-page__no-threads(v-show='!hasThreads && !noGroups')
        span(v-t="'inbox_page.no_threads'")
        span 🙌
      .inbox-page__no-groups(v-show='noGroups')
        p(v-t="'inbox_page.no_groups.explanation'")
        button.lmo-btn-link--blue(v-t="'inbox_page.no_groups.start'", @click='startGroup()')
        span(v-t="'inbox_page.no_groups.or'")
        span(v-t="'inbox_page.no_groups.join_group'")
      .inbox-page__group(v-for='group in orderedGroups', :key='group.id')
        v-card.mb-3(v-if='views[group.key].any()')
          v-card-title
            v-avatar.mr-2(tile size="48px")
              v-img(:src='group.logoUrl()', aria-hidden='true')
            router-link.inbox-page__group-name(:to="'/g/' + group.key")
              span.subheading {{group.name}}
          thread-preview-collection(:query="views[group.key]", :limit="threadLimit")
</template>
