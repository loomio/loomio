<script setup lang="js">
import AppConfig from '@/shared/services/app_config';

const privacyUrl = AppConfig.theme.privacy_url;
const helpUrl = AppConfig.theme.help_url;
const termsUrl = AppConfig.theme.terms_url;
const poweredUrl = '/about-loomio';
const version = AppConfig.version;
</script>
<template lang="pug">
v-footer.d-flex.justify-center
  .powered-by.text-body-small
    a(:href="poweredUrl" v-t="'powered_by.powered_by_loomio'")
    span(v-if="version")
      | &nbsp;
      mid-dot
      | &nbsp;
      | v{{version}}
    span(v-if="privacyUrl")
      | &nbsp;
      mid-dot
      | &nbsp;
      a(:href="privacyUrl" v-t="'powered_by.privacy_policy'" target="_blank")
    span(v-if="termsUrl")
      | &nbsp;
      mid-dot
      | &nbsp;
      a(:href="termsUrl" v-t="'powered_by.terms_of_service'" target="_blank")
    span(v-if="helpUrl")
      | &nbsp;
      mid-dot
      | &nbsp;
      a(:href="helpUrl" v-t="'common.help'" target="_blank")
</template>
