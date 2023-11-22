<script lang="js">
import openModal      from '@/shared/helpers/open_modal';
import AppConfig from '@/shared/services/app_config';

export default 
{
  props: {
    group: Object
  },
  methods: {
    openConfirmModalForJson() {
      openModal({
        component: 'ConfirmModal',
        props: {
          confirm: {
            submit: this.group.export,
            text: {
              title:    'group_export_modal.title',
              helptext: 'group_export_modal.body',
              submit:   'group_export_modal.submit',
              flash:    'group_export_modal.flash'
            }
          }
        }
      });
    },
    openConfirmModalForCSV() {
      openModal({
        component: 'ConfirmModal',
        props: {
          confirm: {
            submit: this.group.exportCSV,
            text: {
              title:    'group_export_modal.title',
              helptext: 'group_export_modal.body',
              submit:   'group_export_modal.submit',
              flash:    'group_export_modal.flash'
            }
          }
        }
      });
    }
  },
  computed: {
    baseUrl() {
      return AppConfig.baseUrl;
    }
  }
};

</script>
<template>

<v-card>
  <v-card-title>
    <h1 class="headline" tabindex="-1" v-t="'export_data_modal.title'"></h1>
    <v-spacer></v-spacer>
    <dismiss-modal-button></dismiss-modal-button>
  </v-card-title>
  <v-card-text>
    <help-link path="en/user_manual/groups/data_export"></help-link>
    <h4 class="my-4" v-t="'export_data_modal.as_csv'"></h4>
    <v-btn @click="openConfirmModalForCSV" v-t="'group_page.options.export_data_as_csv'"></v-btn>
    <h4 class="my-4" v-t="'export_data_modal.as_html'"></h4>
    <v-btn :href="baseUrl + 'g/' + group.key + '/export.html?export=1'" target="_blank" v-t="'group_page.options.export_data_as_html'"></v-btn>
    <h4 class="my-4" v-t="'export_data_modal.as_json'"></h4>
    <v-btn @click="openConfirmModalForJson" v-t="'group_page.options.export_data_as_json'"></v-btn>
  </v-card-text>
</v-card>
</template>
