<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import EventBus from '@/shared/services/event_bus'
import Session from '@/shared/services/session'
import Records from '@/shared/services/records'
import marked from 'marked'
import md5 from 'md5'

export default
  data: ->
    notice: false
    showNotice: false
    reload: false

  mounted: ->
    setInterval =>
      Records.fetch
        path: 'boot/version'
        params:
          version: AppConfig.version
          release: AppConfig.release
          now: Date.now()
      .then(@eatData)
    ,
      1000 * 60 * 5
    EventBus.$on 'systemNotice', @eatData
    @eatData({version: AppConfig.version, notice: AppConfig.systemNotice})

  methods:
    eatData: (data) ->
      @reload = data.reload
      @notice = data.notice
      @showNotice = @reload || (@notice && !Session.user().hasExperienced(md5(@notice)))

    accept: ->
      @showNotice = false
      @notice && Records.users.saveExperience(md5(@notice))
      if @reload
        setTimeout ->
          location.reload()
        , 100

</script>

<template lang="pug">
v-system-bar.system-notice(v-if="showNotice" app color="primary" height="40")
  .d-flex.justify-space-between(style="width: 100%")
    .system-notice__message.text-subtitle-1
      span(v-if="notice" v-marked="notice")
      span(v-else="notice" v-t="'global.messages.app_update'")
    v-btn.system-notice__hide(small outlined @click="accept" v-t="(reload && 'global.messages.reload') || 'dashboard_page.dismiss'")
</template>

<style lang="sass">
.system-notice
  p
    margin-top: 0
    margin-bottom: 0
</style>
