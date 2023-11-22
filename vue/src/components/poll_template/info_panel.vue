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
<template>

<div v-if="pollTemplate">
  <v-alert class="poll-template-info-panel" v-if="pollTemplate.processIntroduction" type="info" text="text" outlined="outlined">
    <formatted-text :model="pollTemplate" column="processIntroduction"></formatted-text>
  </v-alert>
  <v-alert class="poll-template-info-panel" v-else type="info" text="text" outlined="outlined">{{pollTemplate.processSubtitle}}</v-alert>
</div>
</template>
