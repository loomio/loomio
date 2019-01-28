<style lang="scss">
@import 'mixins';
@import 'lmo_card';

.inbox-page{
}

.inbox-page .thread-preview__pin {
  display: none;
}

.inbox-page__group {
  margin-bottom: $cardPaddingSize * 2;
}

.inbox-page__heading{
  margin: 20px 0 20px 13px;
}

.inbox-page__no-threads, .inbox-page__no-groups {
  margin-left: $cardPaddingSize;
}

.inbox-page__group-name a{
  @include fontMedium;
  line-height: 30px;
  color: $grey-on-grey;
  padding-left: $thinPaddingSize;
}

.inbox-page__group-name-container {
  padding: 0 $cardPaddingSize;
}
</style>

<script lang="coffee">
AppConfig      = require 'shared/services/app_config'
Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
InboxService   = require 'shared/services/inbox_service'
ModalService   = require 'shared/services/modal_service'
urlFor         = require 'vue/mixins/url_for'

# import ThreadPreviewCollection from 'vue/components/thread/preview_collection.vue'

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
        section(v-if='views[group.key].any()', role='region', aria-label="$t('inbox_page.threads_from.group') + group.name")
          .inbox-page__group-name-container.lmo-flex
            img.lmo-box--small.pull-left(:src='group.logoUrl()', aria-hidden='true')
            h2.inbox-page__group-name
              router-link(:to="'/g/' + group.key") {{group.name}}
          .inbox-page__groups.thread-previews-container
            thread-preview-collection(:query="views[group.key]", :limit="threadLimit")
</template>
