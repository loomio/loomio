import I18n from '@/i18n'
export default class AnonymousUser
  @singular: 'group'
  @plural: 'groups'
  
  name: I18n.t('common.anonymous')
  username: null
  nameWithTitle: -> @name
