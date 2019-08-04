<script lang="coffee">
export default
  props:
    request: Object
</script>

<template lang="pug">
div
  v-list-item.membership-requests
    v-list-item-avatar
      user-avatar(:user='request.actor()' size='40')
    v-list-item-content
      v-list-item-title.membership-request__name {{request.actor().name || request.actor().email}}
      v-list-item-subtitle.membership-request__introduction {{request.introduction}}

    //- , v-t="'membership_requests_page.ignore'"
    //- , v-t="'membership_requests_page.approve'"
    v-list-item-action(v-if="!request.respondedAt")
      v-list-item-action-text
        time-ago(:date='request.createdAt')
      v-btn.membership-requests-page__approve(text icon @click='approve(request)')
        v-icon mdi-check
    v-list-item-action(v-if="!request.respondedAt")
      v-btn.membership-requests-page__ignore(text icon @click='ignore(request)')
        v-icon mdi-close
</template>
