<script lang="js">
import AppConfig from '@/services/app_config';
import Session from '@/services/session';
import Records from '@/services/records';

export default {
  props: {
    pollTemplate: Object
  }
};

</script>
<template lang="pug">
div(v-if="pollTemplate")
  v-alert.poll-template-info-panel(v-if="pollTemplate.processIntroduction" type="info" text outlined)
    formatted-text(:model="pollTemplate" column="processIntroduction")
  v-alert.poll-template-info-panel(v-else type="info" text outlined) {{pollTemplate.processSubtitle}}
</template>
