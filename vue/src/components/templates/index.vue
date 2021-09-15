<script lang="coffee">
import AppConfig          from '@/shared/services/app_config'
import Records            from '@/shared/services/records'
import Session            from '@/shared/services/session'
import EventBus           from '@/shared/services/event_bus'
import Flash              from '@/shared/services/flash'
import AbilityService     from '@/shared/services/ability_service'
import RecordLoader       from '@/shared/services/record_loader'
import { capitalize, take, keys, every, orderBy, debounce } from 'lodash'
import { subDays, addDays, subWeeks, subMonths } from 'date-fns'

export default
  data: ->
    templates: []
    loaded: false

  created: ->
    EventBus.$on 'signedIn', @init

  beforeDestroy: ->
    EventBus.$off 'signedIn', @init

  mounted: ->
    EventBus.$emit('content-title-visible', false)
    EventBus.$emit 'currentComponent',
      titleKey: @titleKey
      page: 'threadsPage'
      search:
        placeholder: @$t('navbar.search_all_threads')
    @init()

  watch:
    '$route.query': 'refresh'

  methods:
    init: ->
      Records.fetch(path: 'templates').then (data) =>
        @loaded = true

      @watchRecords
        key: 'templatesIndex'
        collections: ['templates']
        query: =>
          @templates = Records.templates.find(groupId: null)

    cloneTemplate: (id) ->
      Records.post
        path: 'templates/clone'
        params:
          id: id
      .then (data) =>
        Flash.success('templates.demo_created')
        @$router.push @urlFor(Records.groups.find(data.groups[0].id))

</script>

<template lang="pug">
v-main
  v-container.templates-page.max-width-1024
    h1.display-1.my-4(tabindex="-1" v-observe-visibility="{callback: titleVisible}" v-t="'templates.start_demo'")
    v-card.mb-3(v-if='!loaded' aria-hidden='true')
      v-list(two-line)
        loading-content(:lineCount='2' v-for='(item, index) in [1,2,3]' :key='index' )

    div(v-if="loaded")
      v-card.my-4(v-for="template in templates")
        v-img(:src="template.record().coverUrl" max-height="120")
        v-card-title {{ template.name }}
        v-card-text {{ template.description }}
        v-card-actions
          v-btn(@click="cloneTemplate(template.id)") Start demo
</template>
