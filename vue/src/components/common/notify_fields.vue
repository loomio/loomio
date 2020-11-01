<script lang="coffee">
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete'
import Session        from '@/shared/services/session'
import {map, filter, find} from 'lodash'

export default
  components:
    RecipientsAutocomplete: RecipientsAutocomplete

  props:
    model: Object

  data: ->
    initialRecipients: []

</script>

<template lang="pug">
.common-notify-fields(v-if="model.id")
  //- p recipientMessage {{model.recipientMessage}}
  //- p recipientUserIds {{model.recipientUserIds}}
  //- p recipientEmails {{model.recipientEmails}}
  //- p recipientAudience {{model.recipientAudience}}
  v-divider.my-6
  v-text-field(
    :label="$t('discussion_form.change_log_label')"
    :placeholder="$t('discussion_form.change_log_placeholder')"
    v-model="model.recipientMessage"
    counter="140")

  recipients-autocomplete(
    :label="$t(model.id ? 'action_dock.notify' : 'common.action.invite')"
    :placeholder="$t('announcement.form.'+model.constructor.singular+'_'+ (model.id ? 'edited' : 'announced')+ '.helptext')"
    :model="model")
</template>
