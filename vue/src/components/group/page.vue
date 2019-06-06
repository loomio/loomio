<script lang="coffee">

import AppConfig         from '@/shared/services/app_config'
import Session           from '@/shared/services/session'
import Records           from '@/shared/services/records'
import EventBus          from '@/shared/services/event_bus'
import AbilityService    from '@/shared/services/ability_service'
import LmoUrlService     from '@/shared/services/lmo_url_service'
import PaginationService from '@/shared/services/pagination_service'
import { subscribeTo }   from '@/shared/helpers/cable'
import urlFor            from '@/mixins/url_for.coffee'
import {compact, head, includes} from 'lodash'

export default
  mixins: [urlFor]

  data: ->
    tab: '#home'
    group: null

  created: ->
    @init()
    EventBus.$on 'signedIn', => @init()

  watch:
    '$route': 'init'

  computed:
    tabs: ->
      'threads polls members subgroups files'.split(' ')

  methods:
    currentTab: ->
      if includes(@tabs, @$route.params.tab)
        @tab = @$route.params.tab
      else
        @tab = head(@tab)

    tabChanged: ->
      @$route.params.tab = @tabs.indexOf(@tabIndex)

    groupKey: ->
      @$route.params.handle || @$route.params.key

    init: ->
      @tabIndex = @tabs.indexOf(@currentTab())
      console.log 'tabIndex', @tabIndex
      Records.groups.findOrFetch(@groupKey()).then (group) =>
        @group = group

        # Records.groups.findOrFetch(@groupKey(), {}, true).then (group) => @group = group

        subscribeTo(@group)
        Records.drafts.fetchFor(@group) if AbilityService.canCreateContentFor(@group)

        maxDiscussions = if AbilityService.canViewPrivateContent(@group)
          @group.discussionsCount
        else
          @group.publicDiscussionsCount

        @pageWindow = PaginationService.windowFor
          current:  parseInt(@$route.params.from or 0)
          min:      0
          max:      maxDiscussions
          pageType: 'groupThreads'

        EventBus.$emit 'currentComponent',
          page: 'groupPage'
          breadcrumbs: compact([@group.parent(), @group])
          key: @group.key
          links:
            canonical:   LmoUrlService.group(@group, {}, absolute: true)
            rss:         LmoUrlService.group(@group, {}, absolute: true, ext: 'xml') if !@group.privacyIsSecret()
            prev:        LmoUrlService.group(@group, from: @pageWindow.prev)         if @pageWindow.prev?
            next:        LmoUrlService.group(@group, from: @pageWindow.next)         if @pageWindow.next?
      , (error) ->
        EventBus.$emit 'pageError', error


</script>

<template lang="pug">
loading(:until='group')
  group-cover-image(:group="group")
  v-container.group-page
    group-page-description-card(:group='group')
    v-tabs(fixed-tabs v-model="tabIndex" @change="tab = tabs[tabIndex]")
      v-tab(:key="'threads'") Threads
      v-tab(:key="'polls'") Polls
      v-tab(:key="'members'") Members
      v-tab(:key="'subgroups'") Subgroups
      v-tab(:key="'files'") Files
    v-card
      group-page-discussions-card(v-if="tab == 'threads'" :group='group' flat)
      current-polls-card(v-if="tab == 'polls'" :model='group' flat)
      poll-common-index-card(v-if="tab == 'polls'" :model='group', :limit='5', :view-more-link='true' flat)
      div(v-if="tab == 'members'")
        membership-requests-card(:group='group' flat)
        membership-card(:group='group' flat)
        membership-card(:group='group', :pending='true' flat)
      subgroups-card(v-if="tab == 'subgroups'" :group='group' flat)
      document-card(v-if="tab == 'files'" :group='group' flat)
      //-     // <outlet name="after-slack-card" model="group"></outlet>
      //-     // <installslack_card group="group"></install_slack_card>
</template>
