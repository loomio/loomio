<script lang="coffee">

AppConfig         = require 'shared/services/app_config'
Session           = require 'shared/services/session'
Records           = require 'shared/services/records'
EventBus          = require 'shared/services/event_bus'
AbilityService    = require 'shared/services/ability_service'
LmoUrlService     = require 'shared/services/lmo_url_service'
ModalService      = require 'shared/services/modal_service'
PaginationService = require 'shared/services/pagination_service'

{ subscribeTo } = require 'shared/helpers/cable'

import Loading from 'vue/components/common/loading.vue'
import GroupTheme from 'vue/components/group/theme.vue'
import GroupPageDescriptionCard from 'vue/components/group/description_card.vue'
import GroupPageDiscussionsCard from 'vue/components/group/discussions_card.vue'
import CurrentPollsCard from 'vue/components/group/current_polls_card.vue'
import MembershipRequestsCard from 'vue/components/group/membership_requests_card.vue'
import MembershipCard from 'vue/components/group/membership_card.vue'
import SubgroupsCard from 'vue/components/group/subgroups_card.vue'
import DocumentCard from 'vue/components/document/card.vue'
import PollCommonIndexCard from 'vue/components/poll/common/index_card.vue'

import urlFor from 'vue/mixins/url_for.coffee'

module.exports =
  components:
    Loading: Loading
    GroupTheme: GroupTheme
    GroupPageDescriptionCard: GroupPageDescriptionCard
  mixins: [urlFor]
  data: ->
    group: null
  created: ->
    console.log "params key", @$route.params.key
    Records.groups.findOrFetch(@$route.params.key, {}, true).then (group) =>
      console.log('group', group)
      @init(group)
    , (error) ->
      # EventBus.broadcast $rootScope, 'pageError', error
  methods:
    init: (group) ->
      @group = group
      subscribeTo(@group)

      Records.drafts.fetchFor(@group) if AbilityService.canCreateContentFor(@group)

      maxDiscussions = if AbilityService.canViewPrivateContent(@group)
        @group.discussionsCount
      else
        @group.publicDiscussionsCount
      # @pageWindow = PaginationService.windowFor
      #   current:  parseInt(LmoUrlService.params().from or 0)
      #   min:      0
      #   max:      maxDiscussions
      #   pageType: 'groupThreads'

      # EventBus.broadcast $rootScope, 'currentComponent',
      #   title: @group.fullName
      #   page: 'groupPage'
      #   group: @group
      #   key: @group.key
      #   links:
      #     canonical:   LmoUrlService.group(@group, {}, absolute: true)
      #     rss:         LmoUrlService.group(@group, {}, absolute: true, ext: 'xml') if !@group.privacyIsSecret()
      #     prev:        LmoUrlService.group(@group, from: @pageWindow.prev)         if @pageWindow.prev?
      #     next:        LmoUrlService.group(@group, from: @pageWindow.next)         if @pageWindow.next?

</script>

<template>
  <div class="loading-wrapper lmo-two-column-layout">
    <loading v-if="!group"></loading>
    <main v-if="group" class="group-page lmo-row">
      <!-- <outlet name="before-group-page" model="group"></outlet> -->
      <group-theme :group="group" :home-page="true"></group-theme>
      <div class="lmo-row">
        <div class="lmo-group-column-left">
          <group-page-description-card :group="group"></group-page-description-card>
          <group-page-discussions-card :group="group"></group-page-discussions-card>
        </div>
        <div class="lmo-group-column-right">
          <!--<outlet name="before-group-page-column-right" model="group"></outlet>-->
          <current-polls-card :model="group"></current-polls-card>
          <membership-request-card :group="group"></membership-request-card>
          <membership-card :group="group"></membership-card>
          <membership-card :group="group" :pending="true"></membership-card>
          <subgroups-card  :group="group"></subgroups-card>
          <document-card   :group="group"></document-card>
          <poll-common-index-card :model="group" :limit="5" :view-more-link="true"></poll-common-index-card>
          <!-- <outlet name="after-slack-card" model="group"></outlet> -->
          <!-- <installslack_card group="group"></install_slack_card> -->
        </div>
      </div>
    </main>
  </div>
</template>
