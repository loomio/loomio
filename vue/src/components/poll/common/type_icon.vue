<script lang="js">
import AppConfig from '@/shared/services/app_config';

export default {
  props: {
    poll: Object
  },
  data() {
    return {
      pollTypes: AppConfig.pollTypes
    }
  }
}
</script>

<template lang="pug">
v-tooltip.poll-common-type-icon(bottom)
  template(v-slot:activator="{ props }")
    common-icon.mr-2(
      v-bind="props"
      :size="24"
      :aria-label="poll.translatedPollType()"
      :name="pollTypes[poll.pollType].material_icon"
    )
  span {{poll.translatedPollType()}}
</template>
