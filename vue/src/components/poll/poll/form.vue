<script lang="coffee">
import {keys, intersection, uniq, without, compact, map, every} from 'lodash-es'
import AppConfig  from '@/shared/services/app_config'
import Vue from 'vue'

export default
  props:
    poll: Object

</script>
<template lang="pug">
.poll-poll-form
  poll-common-form-fields(:poll="poll")
  poll-common-form-options-field(:poll="poll")

  validation-errors(:subject="poll" field="pollOptions")
  poll-common-closing-at-field(:poll="poll")
  poll-common-settings(:poll="poll")
</template>
