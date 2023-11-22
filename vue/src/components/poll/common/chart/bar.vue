<script lang="js">
import Records from '@/shared/services/records';

export default
  ({
    props: {
      options: Array
    }
  });
</script>

<template>

<div class="poll-common-chart-bar">
  <div class="d-flex rounded">
    <div class="rounded text-truncate pa-2" v-for="option in options" :key="option.id" v-if="option.rawScorePercent() > 0" :style="{width: option.rawScorePercent()+'%', 'background-color': option.color}"><span>{{option.optionName()}}</span></div>
  </div>
</div>
</template>
<style lang="sass">
.theme--dark
  .poll-common-chart-bar
    color: #000E
</style>
