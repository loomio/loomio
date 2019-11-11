<script lang="coffee">
import Records        from '@/shared/services/records'
import Flash   from '@/shared/services/flash'

export default
  props:
    request: Object
  methods:
    approve: (membershipRequest) ->
      Records.membershipRequests.approve(membershipRequest).then =>
        # @init()
        Flash.success "membership_requests_page.messages.request_approved_success"

    ignore: (membershipRequest) ->
      Records.membershipRequests.ignore(membershipRequest).then =>
        # @init()
        Flash.success "membership_requests_page.messages.request_ignored_success"

</script>

<template lang="pug">
div
  v-list-item.membership-requests
    v-list-item-avatar
      user-avatar(:user='request.actor()' size='40')
    v-list-item-content
      v-list-item-title.membership-request__name
        span {{request.actor().name || request.actor().email || request.name || request.email }}
        span.caption.lmo-grey-text(v-if="!request.respondedAt")
          space
          mid-dot
          time-ago(:date='request.createdAt')
        span.membership-request__response.caption.lmo-grey-text(v-if="request.respondedAt")
          space
          span(v-t="{ path: 'membership_requests_page.previous_request_response', args: { response: request.formattedResponse(), responder: request.responder().name } }")
          mid-dot
          time-ago(:date='request.respondedAt')
      v-list-item-subtitle.membership-request__introduction {{request.introduction}}

    v-list-item-action(v-if="!request.respondedAt")
      v-btn.membership-requests-page__approve(text icon @click='approve(request)')
        v-icon mdi-check
    v-list-item-action(v-if="!request.respondedAt")
      v-btn.membership-requests-page__ignore(text icon @click='ignore(request)')
        v-icon mdi-close
</template>
<style lang="sass">
.lmo-grey-text
  color: rgba(0, 0, 0, 0.54)
</style>
