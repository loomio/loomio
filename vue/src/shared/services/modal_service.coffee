import EventBus from '@/shared/services/event_bus'

export default new class ModalService
  openNewDiscussionModal: (group) ->
    EventBus.$emit('openModal',
                    component: 'DiscussionForm',
                    titleKey: 'discussion_form.new_discussion_title')

  openStartGroupModal: ->
    EventBus.$emit('openModal',
                    component: 'GroupForm',
                    titleKey: 'group_form.new_organization')
