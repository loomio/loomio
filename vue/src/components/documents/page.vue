<style lang="scss">
@import 'variables';
.documents-page__search-filter {
  position: relative;
  i {
    position: absolute;
    top: 4px;
    right: 4px;
  }
}


.documents-page__actions {
  display: flex;
  flex-direction: row;
  @media(max-width: $tiny-max-px) { flex-direction: column; }
}
</style>

<script lang="coffee">
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import _isEmpty  from 'lodash/isEmpty'
import _debounce from 'lodash/debounce'
import { applyLoadingFunction } from '@/shared/helpers/apply'

export default
  data: ->
    group: {}
    fragment: ''
  created: ->
    # EventBus.broadcast $rootScope, 'currentComponent', { page: 'documentsPage'}
    # applyLoadingFunction @, 'fetchDocuments'
    Records.groups.findOrFetchById(@$route.params.key).then (group) =>
      @group = group
      # EventBus.broadcast $rootScope, 'currentComponent',
      #   group: @group
      #   page: 'documentsPage'
      @fetchDocuments()
    , (error) ->
      # EventBus.broadcast $rootScope, 'pageError', error
  methods:
    fetchDocuments: _debounce ->
      Records.documents.fetchByGroup(@group, @fragment)
    , 250

    documents: (filter) ->
      _.filter @group.allDocuments(), (doc) =>
        _.isEmpty(@fragment) or doc.title.match(///#{@fragment}///i)

    addDocument: ->
      ModalService.open 'DocumentModal', doc: =>
        Records.documents.build
          modelId:   @group.id
          modelType: 'Group'

  computed:
    hasDocuments: ->
      _.some @documents()

    canAdministerGroup: ->
      AbilityService.canAdministerGroup(@group)

    isEmptyGroup: ->
      _isEmpty @group

</script>

<template>
  <div class="loading-wrapper lmo-one-column-layout">
    <loading v-if="isEmptyGroup"></loading>
    <main v-if="!isEmptyGroup" class="documents-page">
      <div class="lmo-group-theme-padding"></div>
      <group-theme :group="group"></group-theme>
      <div class="lmo-card">
        <div class="documents-page__top-bar lmo-flex lmo-flex__space-between lmo-flex__baseline">
          <h2 v-t="'documents_page.title'" class="lmo-h2 md-title"></h2>
          <v-btn @click="addDocument()" v-if="canAdministerGroup" class="md-primary md-raised documents-page__invite">
            <span v-t="'documents_page.add_document'"></span>
          </v-btn>
        </div>
        <p v-if="!group.hasDocuments(true)" v-t="'documents_page.no_documents'" class="lmo-hint-text"></p>
        <div v-if="group.hasRelatedDocuments()" class="documents-page__documents">
          <div md-no-float="true" class="md-block documents-page__search-filter">
            <input v-model="fragment" @input="fetchDocuments()" placeholder="$t('documents_page.fragment_placeholder')" class="membership-page__search-filter">
            <i class="mdi mdi-magnify mdi-24px"></i>
          </div>
          <p v-if="!hasDocuments" v-t="{ path: 'documents_page.no_documents_from_fragment', args: { fragment: fragment } }" class="lmo-hint-text"></p>
          <document-management :group="group" :fragment="fragment"></document-management>
        </div>
      </div>
      <!-- <loading v-if="fetchDocumentsExecuting"></loading> -->
    </main>
  </div>
</template>
