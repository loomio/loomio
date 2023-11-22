<script lang="js">
export default {
  props: {
    poll: Object,
    small: Boolean
  }
};
</script>

<template>

<v-tooltip class="poll-common-type-icon" bottom="bottom">
  <template v-slot:activator="{ on, attrs }">
    <common-icon class="mr-2" v-on="on" v-bind="attrs" :small="small" :aria-label="poll.translatedPollType()" :name="$pollTypes[poll.pollType].material_icon"></common-icon>
  </template><span>{{poll.translatedPollType()}}</span>
</v-tooltip>
</template>
