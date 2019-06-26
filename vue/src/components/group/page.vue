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
import {compact, head, includes, filter} from 'lodash'

export default
  mixins: [UrlFor]

  data: ->
    group: null
    activeTab: @urlFor(@group)

  created: ->
    @init()
    EventBus.$on 'signedIn', => @init()

  watch:
    '$route': 'init'

  computed:
    tabs: ->
      return unless @group
      [
        {id: 0, name: 'threads',   route: @urlFor(@group)}
        {id: 1, name: 'polls',     route: @urlFor(@group, 'polls')},
        {id: 2, name: 'members',   route: @urlFor(@group, 'members')},
        {id: 3, name: 'subgroups', route: @urlFor(@group, 'subgroups')},
        {id: 4, name: 'files',     route: @urlFor(@group, 'files')}
      ].filter (obj) => !(obj.name == "subgroups" && @group.isSubgroup())

  methods:
    init: ->
      Records.groups.findOrFetch(@$route.params.key).then (group) =>
        @group = group

        subscribeTo(@group)
        Records.drafts.fetchFor(@group) if AbilityService.canCreateContentFor(@group)


        EventBus.$emit 'currentComponent',
          page: 'groupPage'
          breadcrumbs: compact([@group.parent(), @group])
          group: @group

      , (error) ->
        EventBus.$emit 'pageError', error

</script>

<template lang="pug">
loading(:until='group')
  group-cover-image(:group="group")
  v-container.group-page
    group-description-card(:group='group')
    v-card
      v-tabs(fixed-tabs v-model="activeTab" show-arrows)
        v-tab(v-for="tab of tabs" :key="tab.id" :to="tab.route" :class="'group-page-' + tab.name + '-tab' " exact)
          span(v-t="'group_page.'+tab.name")
      router-view
</template>
