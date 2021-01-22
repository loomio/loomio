<script lang="coffee">
import Records from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'

export default
  props:
    model: Object
    excludeMembers: Boolean

  data: ->
    count: 0

  methods:
    updateCount: ->
      params = ((@model.id && @model) || (@model.groupId && @model.group()) || {namedId: -> {}}).namedId()
      excludeMembers = (@excludeMembers && {exclude_members: 1}) || {}
      Records.remote.get('announcements/count', Object.assign params, {
        recipient_emails_cmr: @model.recipientEmails.join(',')
        recipient_user_xids: @model.recipientUserIds.join('x')
        recipient_usernames_cmr: []
        recipient_audience: @model.recipientAudience
        ...excludeMembers
      }).then (data) =>
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
  space
  span(v-if="model.recipientAudience && !model.anonymous" v-t="'announcement.form.click_group_to_see_individuals'")
</template>
