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

export default
  mixins: [urlFor]
  data: ->
    group: null

  created: ->
    @init()
    EventBus.$on 'signedIn', => @init()

  watch:
    '$route': 'init'

  methods:
    groupKey: ->
      @$route.params.handle || @$route.params.key

    init: ->
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
          title: @group.fullName
          page: 'groupPage'
          group: @group
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
v-container.lmo-main-container.group-page(grid-list-lg)
  loading(v-if='!group')
  div(v-if='group')
    group-theme(:group='group', :home-page='true')
    v-layout(row)
      // <outlet name="before-group-page" model="group"></outlet>
      v-flex(xs12 md8)
        v-layout(column)
          v-flex
            group-page-description-card(:group='group')
          v-flex
            group-page-discussions-card(:group='group')
      v-flex(xs12 md4)
        v-layout(column)
          v-flex
            // <outlet name="before-group-page-column-right" model="group"></outlet>
            current-polls-card(:model='group')
          v-flex
            membership-requests-card(:group='group')
          v-flex
            membership-card(:group='group')
          v-flex
            membership-card(:group='group', :pending='true')
          v-flex
            subgroups-card(:group='group')
          v-flex
            document-card(:group='group')
          v-flex
            poll-common-index-card(:model='group', :limit='5', :view-more-link='true')
            // <outlet name="after-slack-card" model="group"></outlet>
            // <installslack_card group="group"></install_slack_card>
</template>
