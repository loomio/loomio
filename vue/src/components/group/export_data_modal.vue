<script setup lang="js">
import { useI18n } from 'vue-i18n';
import openModal from '@/shared/helpers/open_modal';

const { group } = defineProps({ group: Object });
const { t } = useI18n();

function openConfirmModal(submit) {
  openModal({
    component: 'ConfirmModal',
    props: {
      confirm: {
        submit,
        text: {
          title: 'group_export_modal.title',
          helptext: 'group_export_modal.body',
          submit: 'group_export_modal.submit',
          flash: 'group_export_modal.flash'
        }
      }
    }
  });
}
</script>
<template lang="pug">
v-card(:title="t('export_data_modal.title')")
  template(v-slot:append)
    dismiss-modal-button
  v-card-text
    h4.my-4 {{ t('export_data_modal.as_csv') }}
    v-btn(variant="tonal" @click="openConfirmModal(() => group.exportCSV())")
      span {{ t('group_page.options.export_data_as_csv') }}
    h4.my-4 {{ t('export_data_modal.as_html') }}
    v-btn.export-data-modal__html(variant="tonal" @click="openConfirmModal(() => group.exportHTML())")
      span {{ t('group_page.options.export_data_as_html') }}
    h4.my-4 {{ t('export_data_modal.as_json') }}
    v-btn(variant="tonal" @click="openConfirmModal(() => group.export())")
      span {{ t('group_page.options.export_data_as_json') }}
    v-divider.my-6
    v-alert(variant="tonal")
      a.text-decoration-underline(target="_blank" href="https://help.loomio.com/en/user_manual/groups/data_export") Read more
      space
      span about exporting your data on help.loomio.com
</template>
