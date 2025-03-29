<script lang="js">
import Records        from '@/shared/services/records';
import Flash   from '@/shared/services/flash';

export default
{
  props: {
    request: Object
  },
  methods: {
    approve(membershipRequest) {
      Records.membershipRequests.approve(membershipRequest).then(() => {
        Flash.success("membership_requests_page.messages.request_approved_success");
      });
    },

    ignore(membershipRequest) {
      Records.membershipRequests.ignore(membershipRequest).then(() => {
        Flash.success("membership_requests_page.messages.request_ignored_success");
      });
    }
  }
};

</script>

<template lang="pug">
v-list.membership-requests(lines="two" density="compact")
  v-list-item
    template(v-slot:prepend)
      user-avatar.mr-2(:user='request.actor()' :size='40')
    v-list-item-title.membership-request__name
      span {{request.actor().name}} &lt;{{request.requestorEmail}}&gt;
      span.text-caption.text-medium-emphasis(v-if="!request.respondedAt")
        space
        mid-dot
        time-ago(:date='request.createdAt')
      span.membership-request__response.text-caption.text-medium-emphasis(v-if="request.respondedAt")
        space
        span(v-t="{ path: 'membership_requests_page.previous_request_response', args: { response: request.formattedResponse(), responder: request.responder().name } }")
        mid-dot
        time-ago(:date='request.respondedAt')
    v-list-item-subtitle.membership-request__introduction {{request.introduction}}
    template(v-slot:append)
      v-btn.membership-requests-page__approve(v-if="!request.respondedAt" text icon @click='approve(request)')
        common-icon(name="mdi-check")
      v-btn.membership-requests-page__ignore(v-if="!request.respondedAt" text icon @click='ignore(request)')
        common-icon(name="mdi-close")
</template>
