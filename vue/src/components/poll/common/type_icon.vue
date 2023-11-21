<script lang="js">
export default {
  props: {
    poll: Object,
    small: Boolean
  }
};
</script>

<template lang="pug">
v-tooltip.poll-common-type-icon(bottom)
  template(v-slot:activator="{ on, attrs }")
    common-icon.mr-2(
      v-on="on"
      v-bind="attrs"
      :small="small"
      :aria-label="poll.translatedPollType()"
      :name="$pollTypes[poll.pollType].material_icon"
    )
  span {{poll.translatedPollType()}}
</template>
