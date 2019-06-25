<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import Session   from '@/shared/services/session'
import Records   from '@/shared/services/records'

export default
  props:
    poll: Object
  data: ->
    showHelpLink: AppConfig.features.app.help_link
    collapsed: Session.user().hasExperienced(@experienceKey)
  created: ->
    if !Session.user().hasExperienced(@experienceKey)
      Records.users.saveExperience(@experienceKey)
  methods:
    hide: ->
      @collapsed = true

    show: ->
      @collapsed = false
  computed:
    experienceKey: -> @poll.pollType + "_tool_tip"

</script>
<template lang="pug">
.poll-common-tool-tip
  .poll-common-tool-tip__expanded(v-if='!collapsed')
    .poll-common-tool-tip__expanded-body(v-t="'poll_' + poll.pollType + '_form.tool_tip_expanded'")
    .poll-common-tool-tip__learn-more-link(v-if='showHelpLink' v-t="'poll_common_form.loomio_school_link'")
    .lmo-flex.lmo-flex__space-around
      v-btn.poll-common-tool-tip__collapse(v-t="'common.ok_got_it'" @click='hide()')
  .poll-common-tool-tip__collapsed(v-if='collapsed')
    span.poll-common-tool-tip__collapsed-body(v-t="'poll_' + poll.pollType + '_form.tool_tip_collapsed'")
    span.poll-common-tool-tip__learn-more(v-t="'common.expand'" @click='show()')
</template>
<style lang="scss">
</style>
