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
<template>

<div>
  <v-alert class="poll-template-info-panel" v-if="discussionTemplate.processIntroduction" type="info" text="text" outlined="outlined">
    <p>{{discussionTemplate.processName}}</p>
    <formatted-text :model="discussionTemplate" column="processIntroduction"></formatted-text>
  </v-alert>
</div>
</template>
