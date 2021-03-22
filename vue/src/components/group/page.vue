<script lang="coffee">

import AppConfig         from '@/shared/services/app_config'
import Session           from '@/shared/services/session'
import Records           from '@/shared/services/records'
import EventBus          from '@/shared/services/event_bus'
import AbilityService    from '@/shared/services/ability_service'
import LmoUrlService     from '@/shared/services/lmo_url_service'
import {compact, head, includes, filter} from 'lodash'
import ahoy from '@/shared/services/ahoy'
import OldPlanBanner from '@/components/group/old_plan_banner'

export default
  components: {
    OldPlanBanner
  }

  data: ->
    group: null
    activeTab: ''
    groupFetchError: null

  created: ->
    @init()
    EventBus.$on 'signedIn', @init

  beforeDestroy: ->
    EventBus.$off 'signedIn', @init

  watch:
    '$route.params.key': 'init'

  computed:
    canEditGroup: ->
      AbilityService.canEditGroup(@group)

    tabs: ->
      return unless @group
      query = ''
      query = '?subgroups='+@$route.query.subgroups if @$route.query.subgroups

      [
        {id: 0, name: 'threads',   route: @urlFor(@group, null)+query}
        {id: 1, name: 'polls',     route: @urlFor(@group, 'polls')+query},
        {id: 2, name: 'members',   route: @urlFor(@group, 'members')+query},
        {id: 4, name: 'files',     route: @urlFor(@group, 'files')+query}
        {id: 5, name: 'subgroups',  route: @urlFor(@group, 'subgroups')+query}
        {id: 6, name: 'settings',  route: @urlFor(@group, 'settings')}
      ].filter (obj) => !(obj.name == "subgroups" && @group.parentId)


    coverImageSrc: ->
      if @group
        @group.coverUrl()
      else
        ''

  methods:
    init: ->
      Records.samlProviders.authenticateForGroup(@$route.params.key)
      Records.groups.findOrFetch(@$route.params.key)
      .then (group) =>
        @group = group
        window.location.host = @group.newHost if @group.newHost
        ahoy.trackView
          groupId: @group.id
          organisationId: @group.parentOrSelf().id
          pageType: 'groupPage'
      .catch (error) =>
        EventBus.$emit 'pageError', error
        EventBus.$emit 'openAuthModal' if error.status == 403 && !Session.isSignedIn()

    openGroupSettingsModal: ->
      return null unless @canEditGroup
      EventBus.$emit 'openModal',
        component: 'GroupForm'
        props:
          group: @group

</script>

<template lang="pug">
v-main
  loading(v-if="!group")
  v-container.group-page.max-width-1024(v-if="group")
    v-img(style="border-radius: 8px" :src="coverImageSrc" eager)
    h1.display-1.my-4(tabindex="-1" v-observe-visibility="{callback: titleVisible}")
      span(v-if="group && group.parentId")
        router-link(:to="urlFor(group.parent())") {{group.parent().name}}
        space
        span.grey--text.text--lighten-1 &gt;
        space
      span.group-page__name.mr-4
        | {{group.name}}
    old-plan-banner(:group="group")
    trial-banner(:group="group")
    group-onboarding-card(:group="group")
    formatted-text.group-page__description(v-if="group" :model="group" column="description")
    join-group-button(:group='group')
    document-list(:model='group')
    attachment-list(:attachments="group.attachments")
    v-divider.mt-4
    v-tabs(v-model="activeTab" center-active background-color="transparent" centered grow show-arrows)
      v-tabs-slider
      v-tab(v-for="tab of tabs" :key="tab.id" :to="tab.route" :class="'group-page-' + tab.name + '-tab' " exact)
        span(v-t="'group_page.'+tab.name")
    router-view
</template>

<style lang="sass">
.group-page-tabs
	.v-tab
		&:not(.v-tab--active)
			color: hsla(0,0%,100%,.85) !important

</style>
