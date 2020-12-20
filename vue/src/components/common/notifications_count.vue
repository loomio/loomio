<script lang="coffee">
import Records from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'

export default
  props:
    model: Object

  data: ->
    count: 0

  methods:
    updateCount: ->
      params = ((@model.id && model) || (@model.groupId && @model.group()) || {namedId: -> {}}).namedId()
      Records.remote.get 'announcements/count', Object.assign params,
        recipient_emails_cmr: @model.recipientEmails.join(',')
        recipient_user_xids: @model.recipientUserIds.join('x')
        recipient_usernames_cmr: []
        recipient_audience: @model.recipientAudience
      .then (data) =>
        @count = data.count

  watch:
    'model.recipientEmails': 'updateCount'
    'model.recipientUserIds': 'updateCount'
    'model.recipientAudience': 'updateCount'
    'model.groupId': 'updateCount'

</script>

<template lang="pug">
p.common-notifications-count.text--secondary.caption
  span(v-if="count == 0" v-t="'announcement.form.notified_none'")
  span(v-if="count == 1" v-t="'announcement.form.notified_singular'")
  span(v-if="count > 1" v-t="{path: 'announcement.form.notified', args: {notified: count}}")
</template>
