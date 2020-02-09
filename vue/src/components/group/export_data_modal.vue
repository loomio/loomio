<script lang="coffee">
import openModal      from '@/shared/helpers/open_modal'
import AppConfig from '@/shared/services/app_config'

export default
  props:
    group: Object
    close: Function
  methods:
    openConfirmModalForJson: ->
      openModal
        component: 'ConfirmModal'
        props:
          confirm:
            submit: @group.export
            text:
              title:    'group_export_modal.title'
              helptext: 'group_export_modal.body'
              submit:   'group_export_modal.submit'
              flash:    'group_export_modal.flash'
  computed:
    baseUrl: ->
      AppConfig.baseUrl

</script>
<template lang="pug">
v-card
  v-card-title
    h1.headline(v-t="'export_data_modal.title'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text
    h4.my-4(v-t="'export_data_modal.as_csv'")
    v-btn(:href="baseUrl + 'g/' + group.key + '/export.csv?export=1'" target="_blank" v-t="'group_page.options.export_data_as_csv'")
    h4.my-4(v-t="'export_data_modal.as_html'")
    v-btn(:href="baseUrl + 'g/' + group.key + '/export.html?export=1'" target="_blank" v-t="'group_page.options.export_data_as_html'")
    h4.my-4(v-t="'export_data_modal.as_json'")
    v-btn(@click="openConfirmModalForJson" v-t="'group_page.options.export_data_as_json'")
</template>
