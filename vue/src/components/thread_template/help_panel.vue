<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import Session from '@/shared/services/session'
import Records from '@/shared/services/records'

export default
  props:
    discussion: Object

  mounted: ->
    @template = Records.discussionTemplates.find(@discussion.discussionTemplateId || @discussion.discussionTemplateKey)

  data: ->
    template: null

</script>
<template lang="pug">
div(v-if="template")
  v-alert.poll-template-info-panel(v-if="template.processIntroduction" type="info" text outlined)
    formatted-text(:model="template" column="processIntroduction")
  v-alert.poll-template-info-panel(v-else type="info" text outlined) {{template.processSubtitle}}
</template>
