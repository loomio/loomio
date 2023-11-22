<script lang="js">
import Records        from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import {flatten, capitalize, includes} from 'lodash-es';

export default {
  props: {
    model: Object,
    showEdit: Boolean,
    hidePreview: Boolean,
    hideDate: Boolean,
    fetch: Boolean,
    placeholder: String
  },

  data() {
    return {documents: []};
  },

  created() {
    if (this.couldHaveDocuments) {
      if (this.model.isA('discussion')) {
        Records.documents.fetchByDiscussion(this.model);
      }

      if (this.model.isA('poll') || this.model.isA('outcome') || this.model.isA('group')) {
        Records.documents.fetchByModel(this.model);
      }

      return this.watchRecords({
        collections: ['documents'],
        query: store => {
          this.documents = store.documents.collection.chain().find({
            modelId: {$in: flatten([this.model.id, this.model.newDocumentIds])},
            modelType: capitalize(this.model.constructor.singular)}
          ).where(doc => !includes(this.model.removedDocumentIds, doc.id)).
            simplesort('createdAt', true).data();
        }
      });
    }
  },

  methods: {
    edit(doc, $mdMenu) {
      EventBus.$emit('initializeDocument', doc, $mdMenu);
    },

    deleteDocument(document) {
      EventBus.$emit('openModal', {
        component: 'ConfirmModal',
        props: {
          confirm: {
            submit: document.destroy,
            text: {
              title:    'comment_form.attachments.remove_attachment',
              helptext: 'poll_common_delete_modal.question',
              submit:   'common.action.delete',
              flash:    'poll_common_delete_modal.success'
            }
          }
        }
      }
      );
    }
  },

  computed: {
    couldHaveDocuments() {
      return this.model.createdAt < (new Date("2020-08-01T00:00:00"));
    },

    showTitle() {
      return (this.model.showDocumentTitle || this.showEdit) &&
      (this.model.hasDocuments() || this.placeholder);
    },

    canDelete() {
      return AbilityService.canEditGroup(this.model.group());
    }
  }
};
</script>

<template>

<section class="document-list" v-if="couldHaveDocuments">
  <p class="caption" v-if="!model.hasDocuments() && placeholder" v-t="placeholder"></p>
  <div class="document-list__documents">
    <div class="attachment-list__item" :class="{'document-list__document--image': document.isAnImage() && !hidePreview}" v-for="document in documents" :key="document.id"><a class="attachment-list__preview" v-if="document.isAnImage() && !hidePreview" :href="document.url" target="_blank"><img :src="document.webUrl" :alt="document.title"/></a>
      <div class="attachment-list__item-details"><a class="document-list__title" :href="document.url" target="_blank">{{ document.title }}</a>
        <v-btn class="ml-2" v-if="canDelete" icon="icon" :aria-label="$t('common.action.delete')" @click="deleteDocument(document)">
          <common-icon size="medium" name="mdi-delete"></common-icon>
        </v-btn>
      </div>
    </div>
  </div>
</section>
</template>
<style lang="sass">
.document-list
  img
    width: 100%
    height: auto

</style>
