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
v-combobox.poll-poll-form__add-option-input(v-model="poll.pollOptionNames" @change="persistOptions()" multiple chips :label="$t('poll_common_form.options')" :placeholder="$t('poll_common_form.options_placeholder')")
  template(v-slot:selection="data")
    poll-option-chip(:name="data.item" :removable="canRemove(data.item)" :remove="removeOptionName" :color="colorFor(data.item)")
</template>
