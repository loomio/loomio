<script lang="coffee">
import Records from '@/shared/services/records'
export default
  props:
    model: Object

  mounted: ->
    @fetchCount()

  methods:
    fetchCount: ->
      Records.announcements.fetch 'size',
        params:
          recipient_audience: @model.recipientAudience
          recipient_user_ids: @model.recipientUserIds
          recipient_emails: @model.recipientUserIds
          "#{@model.constructor.singular}_id": @id
      .then (data) =>
        console.log data

</script>

<template lang="pug">
p.caption.discussion-form__notification-guide.mt-n4.v-messages.theme--light
  | notificationsCoutn
  //- span(v-if="notificationsCount == 1" v-t="'discussion_form.one_person_will_be_notified'")
  //- span(v-if="notificationsCount > 1" v-t="{path: 'discussion_form.count_people_will_be_notified', args: {count: notificationsCount}}")
  //- space
  //- span(v-if="notifyingWholeGroup" v-t="'discussion_form.notify_specifc_people_instead'")
</template>
