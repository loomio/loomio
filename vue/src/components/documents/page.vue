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
    fetchDocumentsExecuting: false
  created: ->
    EventBus.$emit 'currentComponent', { page: 'documentsPage'}
    # applyLoadingFunction @, 'fetchDocuments'
    Records.groups.findOrFetchById(@$route.params.key).then (group) =>
      @group = group
      EventBus.$emit 'currentComponent',
        group: @group
        page: 'documentsPage'
      @fetchDocuments()
    , (error) ->
      EventBus.$emit 'pageError', error
  methods:
    fetchDocuments: _debounce ->
      @fetchDocumentsExecuting = true
      Records.documents.fetchByGroup(@group, @fragment). then =>
        @fetchDocumentsExecuting = false
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

<template lang="pug">
  .loading-wrapper.lmo-one-column-layout
    loading(v-if='isEmptyGroup')
    main.documents-page(v-if='!isEmptyGroup')
      .lmo-group-theme-padding
      group-theme(:group='group')
      .lmo-card
        .documents-page__top-bar.lmo-flex.lmo-flex__space-between.lmo-flex__baseline
          h2.lmo-h2.md-title(v-t="'documents_page.title'")
          v-btn.md-primary.md-raised.documents-page__invite(@click='addDocument()', v-if='canAdministerGroup')
            span(v-t="'documents_page.add_document'")
        p.lmo-hint-text(v-if='!group.hasDocuments(true)', v-t="'documents_page.no_documents'")
        .documents-page__documents(v-if='group.hasRelatedDocuments()')
          .md-block.documents-page__search-filter(md-no-float='true')
            input.membership-page__search-filter(v-model='fragment', @input='fetchDocuments()', placeholder="$t('documents_page.fragment_placeholder')")
            i.mdi.mdi-magnify.mdi-24px
          p.lmo-hint-text(v-if='!hasDocuments', v-t="{ path: 'documents_page.no_documents_from_fragment', args: { fragment: fragment } }")
          document-management(:group='group', :fragment='fragment')
      loading(v-if='fetchDocumentsExecuting')
</template>
