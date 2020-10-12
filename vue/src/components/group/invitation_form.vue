<script lang="coffee">
import GroupService from '@/shared/services/group_service'
import Records        from '@/shared/services/records'
import Session from '@/shared/services/session'
import EventBus from '@/shared/services/event_bus'
import AppConfig      from '@/shared/services/app_config'
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete'

export default
  components:
    RecipientsAutocomplete: RecipientsAutocomplete

  props:
    group: Object

  data: ->
    memberships: []
    query: ''
    searchResults: []
    recipients: []
    excludedUserIds: []
    membershipsByUserId: {}
    memberUserIds: []
    reset: false
    saving: false

  mounted: ->
    @watchRecords
      collections: ['memberships']
      query: (records) => @updateMemberships()

  methods:
    updateMemberships: ->


</script>
<template lang="pug">
.group-invitation-form
  .px-4.pt-4
    .d-flex.justify-space-between
      h1.headline(tabindex="-1" v-t="{path: 'announcement.send_group', args: {name: group.name} }")
      dismiss-modal-button
    recipients-autocomplete(
      :label="$t('announcement.form.group_announced.helptext')"
      :placeholder="$t('announcement.form.placeholder')"
      :group="group"
      :excluded-user-ids="excludedUserIds"
      :reset="reset"
      @new-query="newQuery"
      @new-recipients="newRecipients")

    p subgroups

    p invitation message

    .d-flex
      v-spacer
      v-btn(color="primary" :disabled="!recipients.length" @click="inviteRecipients" @loading="saving" v-t="'common.action.invite'")

</template>
