<style lang="scss">
@import 'mixins';
@import 'lmo_card';

.inbox-page{
  @include lmoRow;
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
    # EventBus.broadcast $rootScope, 'currentComponent', {titleKey: 'inbox_page.unread_threads' ,page: 'inboxPage'}
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
      _.sortBy @groups(), 'name'
</script>

<template>
  <div class="lmo-one-column-layout">
    <main class="inbox-page">
        <div class="thread-preview-collection__container">
            <h1 v-t="'inbox_page.unread_threads'" class="lmo-h1-medium inbox-page__heading"></h1>
            <section v-if="loading" aria-hidden="true" class="dashboard-page__loading">
                <div class="thread-previews-container">
                    <!-- <loading_content line-count="2" ng-repeat="i in [1,2,3,4,5,6,7,8,9,10] track by $index" class="thread-preview"></loading_content> -->
                </div>
            </section>
            <section v-if="!loading" class="inbox-page__threads">
                <div v-show="!hasThreads && !noGroups" class="inbox-page__no-threads">
                  <span v-t="'inbox_page.no_threads'"></span>
                  <span></span>
                  🙌
                </div>
                <div v-show="noGroups" class="inbox-page__no-groups">
                  <p v-t="'inbox_page.no_groups.explanation'"></p>
                  <button v-t="'inbox_page.no_groups.start'" @click="startGroup()" class="lmo-btn-link--blue"></button>
                  <span v-t="'inbox_page.no_groups.or'"></span>
                  <span v-t="'inbox_page.no_groups.join_group'"></span>
                </div>
                <div v-for="group in orderedGroups" :key="group.id" class="inbox-page__group">
                    <section v-if="views[group.key].any()" role="region" aria-label="$t('inbox_page.threads_from.group') + group.name">
                        <div class="inbox-page__group-name-container lmo-flex">
                          <img :src="group.logoUrl()" aria-hidden="true" class="lmo-box--small pull-left">
                          <h2 class="inbox-page__group-name">
                            <router-link :to="'/g/' + group.key">{{group.name}}</router-link>
                          </h2>
                        </div>
                        <div class="inbox-page__groups thread-previews-container">
                          <!-- <thread-preview-collection :query="views[group.key]" :limit="threadLimit"></thread-preview-collection> -->
                        </div>
                    </section>
                </div>
            </section>
        </div>
    </main>
</div>
</template>
