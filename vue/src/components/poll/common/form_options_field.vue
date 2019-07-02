<script lang="coffee">
import PollFormOptionsMixin from '@/mixins/poll_form_options'

export default
  mixins: [PollFormOptionsMixin]
  props:
    poll: Object
    addOptionsOnly:
      type: Boolean
      default: false
</script>

<template lang="pug">
v-combobox(v-model="poll.pollOptionNames" @change="persistOptions()" multiple chips :label="$t('poll_common_form.options')" :placeholder="$t('poll_common_form.options_placeholder')")
  template(v-slot:selection="data")
    v-chip(:close="canRemove(data.item)" :color="colorFor(data.item)" @click.stop="removeOptionName(data.item)") {{data.item}}
</template>
