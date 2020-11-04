<script lang="coffee">
import AppConfig          from '@/shared/services/app_config'
import Records            from '@/shared/services/records'
import Session            from '@/shared/services/session'
import EventBus           from '@/shared/services/event_bus'
import AbilityService     from '@/shared/services/ability_service'
import RecordLoader       from '@/shared/services/record_loader'
import ThreadFilter       from '@/shared/services/thread_filter'
import { capitalize, take, keys, every, orderBy, debounce } from 'lodash'
import { subDays, addDays, subWeeks, subMonths } from 'date-fns'

export default
  data: ->
    threads: []
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
      Records.discussions.fetch(path: 'direct').then => @loaded = true

      @watchRecords
        key: 'dashboard'
        collections: ['discussions', 'searchResults']
        query: =>
          @threads = Records.discussions.find(groupId: null)

</script>

<template lang="pug">
v-main
  v-container.threads-page.max-width-1024
    h1.display-1.my-4(tabindex="-1" v-observe-visibility="{callback: titleVisible}" v-t="'sidebar.direct_threads'")
    v-layout.mb-3
      //- v-text-field(clearable solo hide-details :value="$route.query.q" @input="onQueryInput" :placeholder="$t('navbar.search_all_threads')" append-icon="mdi-magnify")

    v-card.mb-3.dashboard-page__loading(v-if='!loaded' aria-hidden='true')
      v-list(two-line)
        loading-content(:lineCount='2' v-for='(item, index) in [1,2,3]' :key='index' )
    div(v-if="loaded")
      section.threads-page__loaded
        .threads-page__empty(v-if='threads.length == 0')
          p(v-t="'threads_page.no_direct_threads'")
        .threads-page__collections(v-else)
          v-card.mb-3.thread-preview-collection__container
            thread-preview-collection.thread-previews-container(:threads='threads')
</template>
<style lang="sass">
// .threads-page
// 	.thread-preview__pin
// 		display: none
// .threads-page__heading
// 	margin: 20px 0 20px 13px
// .threads-page__date-range
// .threads-page__no-threads,
// .threads-page__no-groups,
// .threads-page__explain-mute
// .threads-page__footer
// 	height: 1px
// 	position: relative
// 	bottom: 200px
// .threads-page__mute-image--large
// 	text-align: center
// 	margin: 0 0 10px
// .threads-page__mute-image--small
// 	text-align: center
// 	margin: 0 0 10px

</style>
