<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import EventBus from '@/shared/services/event_bus'
import Session from '@/shared/services/session'
import Records from '@/shared/services/records'
import marked from 'marked'
import md5 from 'md5'

export default
  data: ->
    notice: ''
    showNotice: true

  mounted: ->
    EventBus.$on 'systemNotice', (data) =>
      @notice = data.notice
      @showNotice = !Session.user().hasExperienced(md5(@notice))
    @notice = AppConfig.systemNotice || ''
    @showNotice = !Session.user().hasExperienced(md5(@notice))

  methods:
    hideNotice: ->
      Records.users.saveExperience(md5(@notice))
      @showNotice = false

</script>

<template lang="pug">
v-system-bar.system-notice(v-if="notice && showNotice" app)
  .d-flex.justify-space-between(style="width: 100%")
    .system-notice__message(v-marked="notice")
    a.pl-2.system-notice__hide(@click="hideNotice" v-t="'dashboard_page.dismiss'")
</template>

<style lang="sass">
.system-notice
  p
    margin-top: 0
    margin-bottom: 0
</style>
