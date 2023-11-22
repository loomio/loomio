<script lang="js">
import AppConfig from '@/shared/services/app_config';

export default {
  data() {
    return {
      privacyUrl: AppConfig.theme.privacy_url,
      helpUrl: AppConfig.theme.help_url,
      termsUrl: AppConfig.theme.terms_url,
      hostname: AppConfig.theme.canonical_host,
      poweredUrl: `https://www.loomio.com?utm_source=${AppConfig.theme.canonical_host}&utm_campaign=appfooter`
    };
  }
};

</script>
<template>

<v-footer>
  <v-layout justify-space-around="justify-space-around">
    <div class="powered-by caption"><a :href="poweredUrl" v-t="'powered_by.powered_by_loomio'" target="_blank"></a><span v-if="privacyUrl">&nbsp;
        <mid-dot></mid-dot>&nbsp;<a :href="privacyUrl" v-t="'powered_by.privacy_policy'" target="_blank"></a></span><span v-if="termsUrl">&nbsp;
        <mid-dot></mid-dot>&nbsp;<a :href="termsUrl" v-t="'powered_by.terms_of_service'" target="_blank"></a></span><span v-if="helpUrl">&nbsp;
        <mid-dot></mid-dot>&nbsp;<a :href="helpUrl" v-t="'common.help'" target="_blank"></a></span></div>
  </v-layout>
</v-footer>
</template>
