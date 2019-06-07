<script lang="coffee">

import AppConfig         from '@/shared/services/app_config'
import Session           from '@/shared/services/session'
import Records           from '@/shared/services/records'
import EventBus          from '@/shared/services/event_bus'
import AbilityService    from '@/shared/services/ability_service'
import LmoUrlService     from '@/shared/services/lmo_url_service'
import PaginationService from '@/shared/services/pagination_service'
import { subscribeTo }   from '@/shared/helpers/cable'
import UrlFor        from '@/mixins/url_for.coffee'
import {compact, head, includes} from 'lodash'

export default
  mixins: [UrlFor]

  data: ->
    group: null
    activeTab:  @urlFor(@group)

  created: ->
    @init()
    EventBus.$on 'signedIn', => @init()

  watch:
    '$route': 'init'

  computed:
    tabs: ->
      [
        {id: 0, name: 'threads',   route: @urlFor(@group)}
        {id: 1, name: 'polls',     route: @urlFor(@group, 'polls')},
        {id: 2, name: 'members',   route: @urlFor(@group, 'members')},
        {id: 3, name: 'subgroups', route: @urlFor(@group, 'subgroups')},
        {id: 4, name: 'files',     route: @urlFor(@group, 'files')}
      ]

  methods:
    init: ->
      console.log "activeTab", @activeTab
      console.log "group page route", @$route
      Records.groups.findOrFetch(@$route.params.key).then (group) =>
        @group = group

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
    group-description-card(:group='group')
    v-card
      v-tabs(fixed-tabs v-model="activeTab")
        v-tab(v-for="tab of tabs" :key="tab.id" :to="tab.route" exact)
          | {{tab.name}}
        v-tab-item(v-for="tab of tabs" :key="tab.id" :value="tab.route")
          router-view(v-if="activeTab == tab.route")
        //- v-card
        //-   group-page-discussions-panel(v-if="tab == 'threads'" :group='group' flat)
        //-   current-polls-card(v-if="tab == 'polls'" :model='group' flat)
        //-   poll-common-index-card(v-if="tab == 'polls'" :model='group', :limit='5', :view-more-link='true' flat)
        //-   div(v-if="tab == 'members'")
        //-     membership-requests-card(:group='group' flat)
        //-     membership-card(:group='group' flat)
        //-     membership-card(:group='group', :pending='true' flat)
        //-   subgroups-card(v-if="tab == 'subgroups'" :group='group' flat)
        //-   document-card(v-if="tab == 'files'" :group='group' flat)
        //-     // <outlet name="after-slack-card" model="group"></outlet>
        //-     // <installslack_card group="group"></install_slack_card>
</template>
