<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import Session from '@/shared/services/session'
import Records from '@/shared/services/records'

export default
  props:
    poll: Object

  mounted: ->
    # Records.remote.fetch(path: "poll_templates", params: {group_id: @group.id} )
    @pollTemplate = Records.pollTemplates.find(@poll.pollTemplateId || @poll.pollTemplateKey)
    # @watchRecords
    #   key: 'pollTemplateInfoPanel'
    #   collections: ["pollTemplates"]
    #   query: (records) =>
    #     @pollTemplate = Records.pollTemplates.find(@poll.pollTemplateId || @poll.pollTemplateKey)

  data: ->
    pollTemplate: null

</script>
<template lang="pug">
div
  //- p.text--secondary(v-if="false") {{pollTemplate.processSubtitle}}
  v-alert.poll-template-info-panel(v-if="pollTemplate && pollTemplate.processIntroduction" type="info" text outlined)
    formatted-text(:model="pollTemplate" column="processIntroduction")
  v-alert.poll-template-info-panel(v-else type="info" text outlined) {{pollTemplate.processSubtitle}}

</template>
