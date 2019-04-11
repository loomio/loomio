<style>
</style>

<script lang="coffee">
import bowser from 'bowser'
import AppConfig from '@/shared/services/app_config'

export default {
  props:
  data: ->
    browser: bowser
    siteName: AppConfig.theme.site_name
}
</script>

<template>
  <div class="browser-warning">
    <span v-t="{ path: 'browser_warning.message', args: { name: browser.name, version: browser.version, site: siteName } }"></span>
    <router-link to="https://browser-update.org/update-browser.html" v-t="'browser_warning.link'"></router-link>
  </div>
</template>
