<style lang="scss">
@import 'variables';
.document-management {
  margin-bottom: 16px;
}

.document-management__caption {
  color: $grey-on-white;
}

.document-management__icon {
  font-size: 24px;
}

.document-management__column-row {
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  margin: 8px 0;
  i { padding: 4px; }
}

</style>

<script lang="coffee">
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import urlFor         from '@/mixins/url_for'
import truncate       from '@/mixins/truncate'

export default
  mixins: [urlFor, truncate]
  props:
    group: Object
    fragment: Object
    filter: Object
    header: Object
  data: ->
    isRemoveModalOpen: false
  methods:
    canAdministerGroup: ->
      AbilityService.canAdministerGroup(@group)

    edit: (doc) ->
      ModalService.open 'DocumentModal', doc: => doc

    closeRemoveModal: ->
      @isRemoveModalOpen = false
    openRemoveModal: ->
      @isRemoveModalOpen = true
    removeModalConfirmOpts: (doc) ->
      submit:      doc.destroy
      text:
        title:    'documents_page.confirm_remove_title'
        helptext: 'documents_page.confirm_remove_helptext'
        flash:    'documents_page.document_removed'
  computed:
    documents: ->
      _.filter @group.allDocuments(), (doc) =>
        return false  if @filter == 'group'   and doc.model() != @group
        return false  if @filter == 'content' and doc.model() == @group
        _.isEmpty(@fragment) or doc.title.match(///#{@fragment}///i)

    orderedDocuments: ->
      _.orderBy @documents, 'createdAt', 'desc'

    hasDocuments: ->
      _.some @documents
</script>

<template lang="pug">
.document-management(v-if='hasDocuments')
  h3.lmo-h3(v-t="'document.management.' + filter + '_header'", v-if='filter')
  .document-management__document.lmo-flex.lmo-flex__space-between(v-for='document in orderedDocuments', :key='document.id', layout='row')
    .document-management__column-row
      i(:class="'mdi lmo-margin-right document-management__icon mdi-' + document.icon", :style='{color: document.color}')
    .document-management__column-row.lmo-flex.lmo-flex__grow(layout='column')
      strong.lmo-truncate
        router-link(:to='document.url', target='_blank') {{ truncate(document.title, 50) }}
      .document-management__caption.md-caption
        router-link.lmo-truncate(:to='urlFor(document.model())') {{ truncate(document.modelTitle(), 50) }}
      .document-management__caption.md-caption
        span {{document.authorName()}}
        span ·
        time-ago(:date='document.createdAt')
    .document-management__column-row(v-if='canAdministerGroup()')
      button.md-accent(@click='edit(document)', v-t="'common.action.edit'")
    .document-management__column-row(v-if='canAdministerGroup()')
      button.md-warn(@click='openRemoveModal', v-t="'common.action.remove'")
      v-dialog(v-model="isRemoveModalOpen", lazy persistent)
        confirm-modal(:confirm="removeModalConfirmOpts(document)", :close="closeRemoveModal")
</template>
