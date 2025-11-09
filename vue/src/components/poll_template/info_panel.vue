<script lang="js">
import AppConfig from '@/shared/services/app_config';
import Session from '@/shared/services/session';
import Records from '@/shared/services/records';

export default {
  props: {
    pollTemplate: Object
  }
};

</script>
<template lang="pug">
div(v-if="pollTemplate")
  v-alert.poll-template-info-panel(v-if="!pollTemplate.attributeIsBlank('processIntroduction')" type="info" text variant="tonal")
    formatted-text(:model="pollTemplate" field="processIntroduction")
  v-alert.poll-template-info-panel(v-else type="info" text variant="tonal") {{pollTemplate.processSubtitle}}
</template>
