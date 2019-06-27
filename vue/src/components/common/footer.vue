<script lang="coffee">
import AppConfig from '@/shared/services/app_config'

export default
  data: ->
    privacyUrl: AppConfig.theme.privacy_url
    termsUrl: AppConfig.theme.terms_url
    frontPageUrl: AppConfig.baseUrl + "?frontpage"
    showFrontPage: AppConfig.baseUrl != "https://www.loomio.org/"

</script>
<template lang="pug">
v-footer
  v-layout(justify-space-around)
    .powered-by.caption
      a(href="https://www.loomio.org/?frontpage" v-t="'powered_by.powered_by_loomio'" target="_blank")
      span(v-if="privacyUrl")
      | &nbsp;
      | ·
      | &nbsp;
      a(:href="privacyUrl" v-t="'powered_by.privacy_policy'" target="_blank")
      span(v-if="termsUrl")
      | &nbsp;
      | ·
      | &nbsp;
      a(:href="termsUrl" v-t="'powered_by.terms_of_service'" target="_blank")
      span(v-if="showFrontPage")
      | &nbsp;
      | ·
      | &nbsp;
      a(:href="frontPageUrl" v-t="'powered_by.front_page'" target="_blank")
</template>
