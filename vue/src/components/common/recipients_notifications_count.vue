<script lang="coffee">
export default
  props:
    recipients: Array

  computed:
    notifyingWholeGroup: ->
      (@recipients.length == 1) && @recipients[0].type == 'group'

    notificationsCount: ->
      if @notifyingWholeGroup
        @recipients[0].group.acceptedMembershipsCount
      else
        @recipients.filter((r) -> r.type != 'group').length

</script>

<template lang="pug">
p.caption.discussion-form__notification-guide.mt-n4.v-messages.theme--light(v-if="notificationsCount")
  span(v-if="notificationsCount == 1" v-t="'discussion_form.one_person_will_be_notified'")
  span(v-if="notificationsCount > 1" v-t="{path: 'discussion_form.count_people_will_be_notified', args: {count: notificationsCount}}")
  space
  span(v-if="notifyingWholeGroup" v-t="'discussion_form.notify_specifc_people_instead'")
</template>
