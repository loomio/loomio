<script lang="js">
import AppConfig from '@/shared/services/app_config';
import Session from '@/shared/services/session';
import Records from '@/shared/services/records';

export default {
  props: {
    discussionTemplate: Object
  }
};

</script>
<template lang="pug">
v-alert.poll-template-info-panel.mb-6(v-if="discussionTemplate.processIntroduction" type="info" variant="tonal")
  p {{discussionTemplate.processName}}
  formatted-text(:model="discussionTemplate" field="processIntroduction")
</template>
