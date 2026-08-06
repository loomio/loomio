<script setup>
import Session from '@/shared/services/session';

const { error } = defineProps({
  error: Object
});

const isSignedIn = Session.isSignedIn();
</script>
<template lang="pug">
v-main.pb-12
  v-container
    .error-page.text-center
      v-alert.error-page__forbidden(v-if="error.status == 403" type="error")
        div(v-t="'error_page.forbidden_view'")
        div.mt-2(v-if="isSignedIn" v-t="'error_page.signed_in_account_tip'")
      .error-page__page-not-found(v-t="'error_page.page_not_found'" v-if="error.status == 404")
      .error-page__internal-server-error(v-t="'error_page.internal_server_error'" v-if="error.status == 500")
</template>
