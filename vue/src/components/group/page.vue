<script lang="coffee">

import AppConfig         from '@/shared/services/app_config'
import Session           from '@/shared/services/session'
import Records           from '@/shared/services/records'
import EventBus          from '@/shared/services/event_bus'
import AbilityService    from '@/shared/services/ability_service'
import LmoUrlService     from '@/shared/services/lmo_url_service'
import InstallSlackModalMixin from '@/mixins/install_slack_modal'
import GroupModalMixin from '@/mixins/group_modal'
import { subscribeTo }   from '@/shared/helpers/cable'
import {compact, head, includes, filter} from 'lodash'

export default
  mixins: [InstallSlackModalMixin, GroupModalMixin]
  data: ->
    group: null
    activeTab: ''
    groupFetchError: null

  created: ->
    @init()
    EventBus.$on 'signedIn', => @init()

  watch:
    '$route.params.key': 'init'

  computed:
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
      ].filter (obj) => !(obj.name == "subgroups" && @group.isSubgroup())

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
        subscribeTo(@group)
        @openInstallSlackModal(@group) if @$route.query.install_slack
      .catch (error) =>
        EventBus.$emit 'pageError', error
        EventBus.$emit 'openAuthModal' if error.status == 403

    titleVisible: (visible) ->
      EventBus.$emit('content-title-visible', visible)

</script>

<template lang="pug">
v-content
  loading(v-if="!group")
  v-container.group-page.max-width-1024(v-else)
    v-img(style="border-radius: 8px" :src="coverImageSrc" eager)
    h1.display-1.my-4(v-observe-visibility="{callback: titleVisible}")
      span(v-if="group && group.parent()")
        router-link(:to="urlFor(group.parent())") {{group.parent().name}}
        space
        span.grey--text.text--lighten-1 &gt;
        space
      span.group-page__name.mr-4
        | {{group.name}}
    trial-banner(:group="group")
    group-onboarding-card(v-if="group" :group="group")
    formatted-text.group-page__description(v-if="group" :model="group" column="description")
    document-list(:model='group')
    attachment-list(:attachments="group.attachments")
    v-divider.mt-4
    v-tabs(v-model="activeTab" center-active background-color="transparent" centered grow)
      v-tab(v-for="tab of tabs" :key="tab.id" :to="tab.route" :class="'group-page-' + tab.name + '-tab' " exact)
        span(v-t="'group_page.'+tab.name")
    join-group-button(:group='group')
    router-view
</template>

<style lang="sass">
.group-page-tabs
	.v-tab
		&:not(.v-tab--active)
			color: hsla(0,0%,100%,.85) !important

</style>
