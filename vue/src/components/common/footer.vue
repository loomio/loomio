<script lang="coffee">
import AppConfig from '@/shared/services/app_config'

export default
  data: ->
    privacyUrl: AppConfig.theme.privacy_url
    helpUrl: AppConfig.theme.help_url
    termsUrl: AppConfig.theme.terms_url
    hostname: AppConfig.theme.canonical_host
    poweredUrl: "https://www.loomio.com?utm_source=#{AppConfig.theme.canonical_host}&utm_campaign=appfooter"

</script>
<template lang="pug">
v-footer
  v-layout(justify-space-around)
    .powered-by.caption
      a(:href="poweredUrl" v-t="'powered_by.powered_by_loomio'" target="_blank")
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
