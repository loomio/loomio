<script lang="coffee">
import PollFormOptionsMixin from '@/mixins/poll_form_options'

export default
  mixins: [PollFormOptionsMixin]

  props:
    poll: Object
    addOptionsOnly:
      type: Boolean
      default: false

  data: ->
    menu: false

</script>

<template lang="pug">
.poll-meeting-form-options
  v-menu(ref="menu" v-model="menu" :close-on-content-click="false" offset-y full-width min-width="290px")
    template(v-slot:activator="{ on }" )
      v-combobox.poll-meeting-time-field__datepicker-container(v-on="on" v-model="poll.pollOptionNames" @change="persistOptions()" multiple chips small-chips deletable-chips :label="$t('poll_meeting_form.timeslots')")
        template(v-slot:selection="data")
          v-chip(:close="canRemove(data.item)" :color="colorFor(data.item)" @click:close="removeOptionName(data.item)")
            poll-meeting-time(:name="data.item")
    poll-meeting-add-option-menu(@close="menu = false" :poll="poll")
  validation-errors(:subject="poll" field="pollOptions")
</template>
