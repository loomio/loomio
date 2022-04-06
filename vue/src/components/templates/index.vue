<script lang="coffee">
import AuthModalMixin      from '@/mixins/auth_modal'
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
  mixins: [ AuthModalMixin ]
  data: ->
    templates: []
    loaded: false
    processing: false
    trials: AppConfig.features.app.trials

  created: ->
    EventBus.$on 'signedIn', @init

  beforeDestroy: ->
    EventBus.$off 'signedIn', @init

  mounted: ->
    EventBus.$emit('content-title-visible', false)
    EventBus.$emit 'currentComponent',
      titleKey: 'templates.try_loomio'
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
          @templates = Records.templates.collection.chain().find(groupId: null).simplesort('priority', true).data()

    startDemo: (id) ->
      if Session.isSignedIn()
        @cloneTemplate(id)
      else
        @openAuthModal()

    cloneTemplate: (id) ->
      Flash.wait('templates.generating_demo')
      @processing = true
      Records.post
        path: 'templates/clone'
        params:
          id: id
      .then (data) =>
        Flash.success('templates.demo_created')
        @$router.push @urlFor(Records.groups.find(data.groups[0].id))
      .finally =>
        @processing = false

</script>

<template lang="pug">
v-main
  v-container.templates-page.max-width-1024
    h1.display-1.my-4(tabindex="-1" v-observe-visibility="{callback: titleVisible}" v-t="'templates.try_loomio'")
    h2.text-title.my-4(v-t="'templates.start_a_demo'")
    p
      span(v-t="'templates.look_and_feel'")
      space
      span(v-t="'templates.demos_expire'")
    v-card.mb-3(v-if='!loaded' aria-hidden='true')
      v-list(two-line)
        loading-content(:lineCount='2' v-for='(item, index) in [1,2,3]' :key='index' )

    v-overlay(:value="processing")
    div(v-if="loaded")
      v-card.my-4(v-for="template in templates" :key="template.id")
        v-img(:src="template.record().coverUrl" max-height="120")
        v-card-title {{ template.name }}
        v-card-text {{ template.description }}
        v-card-actions
          v-spacer
          v-btn(@click="startDemo(template.id)" v-t="'templates.start_demo'" color="primary")

    template(v-if="trials")
      h2.mt-8.text-title(v-t="'templates.ready_to_trial'")
      v-card.my-4
        v-card-title(v-t="{path:'templates.start_a_x_day_free_trial', args: {day: 7}}")
        v-card-text
          span(v-t="{path: 'templates.start_a_no_obligation_x_day_trial', args: {day: 7}}")
          space
          span(v-t="'templates.you_can_test_it_out'")
        v-card-actions
          v-spacer
          v-btn(to="/g/new" color="primary" v-t="'templates.start_trial'")
</template>
