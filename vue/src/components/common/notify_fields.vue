<script lang="coffee">
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete'
import Session        from '@/shared/services/session'
import {map, filter, find} from 'lodash'

export default
  components:
    RecipientsAutocomplete: RecipientsAutocomplete

  props:
    model: Object

    initialRecipients:
      type: Array
      default: []

</script>

<template lang="pug">
.common-notify-fields
  v-divider.my-6
  v-text-field(
    v-if="model.id"
    :label="$t('discussion_form.change_log_label')"
    :placeholder="$t('discussion_form.change_log_placeholder')"
    v-model="model.recipientMessage")

  recipients-autocomplete(
    :label="$t(model.id ? 'action_dock.notify' : 'common.action.invite')"
    :placeholder="$t('announcement.form.'+model.constructor.singular+'_'+ (model.id ? 'edited' : 'announced')+ '.helptext')"
    :initial-recipients="initialRecipients"
    :model="model")
</template>
