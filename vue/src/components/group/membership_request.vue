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

<template>

<div>
  <v-list-item class="membership-requests">
    <v-list-item-avatar>
      <user-avatar :user="request.actor()" :size="40"></user-avatar>
    </v-list-item-avatar>
    <v-list-item-content>
      <v-list-item-title class="membership-request__name"><span>{{request.actor().name}} <{{request.requestorEmail}}></span><span class="caption text--secondary" v-if="!request.respondedAt">
          <space></space>
          <mid-dot></mid-dot>
          <time-ago :date="request.createdAt"></time-ago></span><span class="membership-request__response caption text--secondary" v-if="request.respondedAt">
          <space></space><span v-t="{ path: 'membership_requests_page.previous_request_response', args: { response: request.formattedResponse(), responder: request.responder().name } }"></span>
          <mid-dot></mid-dot>
          <time-ago :date="request.respondedAt"></time-ago></span></v-list-item-title>
      <v-list-item-subtitle class="membership-request__introduction">{{request.introduction}}</v-list-item-subtitle>
    </v-list-item-content>
    <v-list-item-action v-if="!request.respondedAt">
      <v-btn class="membership-requests-page__approve" text="text" icon="icon" @click="approve(request)">
        <common-icon name="mdi-check"></common-icon>
      </v-btn>
    </v-list-item-action>
    <v-list-item-action v-if="!request.respondedAt">
      <v-btn class="membership-requests-page__ignore" text="text" icon="icon" @click="ignore(request)">
        <common-icon name="mdi-close"></common-icon>
      </v-btn>
    </v-list-item-action>
  </v-list-item>
</div>
</template>
