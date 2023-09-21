<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import Session from '@/shared/services/session'
import Records from '@/shared/services/records'

export default
  props:
    discussionTemplate: Object

</script>
<template lang="pug">
div
  v-alert.poll-template-info-panel(v-if="discussionTemplate.processIntroduction" type="info" text outlined)
    p {{discussionTemplate.processName}}
    formatted-text(:model="discussionTemplate" column="processIntroduction")
</template>
