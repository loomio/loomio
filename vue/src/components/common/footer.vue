<script setup lang="js">
import AppConfig from '@/shared/services/app_config';

const privacyUrl = AppConfig.theme.privacy_url;
const termsUrl = AppConfig.theme.terms_url;
const poweredUrl = '/about-loomio';
</script>
<template lang="pug">
v-footer.d-flex.flex-grow-0.justify-center
  .powered-by.text-body-small.text-medium-emphasis
    a.text-medium-emphasis(:href="poweredUrl" v-t="'powered_by.powered_by_loomio'")
    span(v-if="privacyUrl")
      | &nbsp;
      mid-dot
      | &nbsp;
      a.text-medium-emphasis(:href="privacyUrl" v-t="'powered_by.privacy_policy'" target="_blank")
    span(v-if="termsUrl")
      | &nbsp;
      mid-dot
      | &nbsp;
      a.text-medium-emphasis(:href="termsUrl" v-t="'powered_by.terms_of_service'" target="_blank")
</template>
