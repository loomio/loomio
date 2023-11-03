import I18n from '@/i18n';

export default class AnonymousUser {
  static singular = 'group';
  static plural = 'groups';

  constructor() {
    this.name = I18n.t('common.anonymous');
    this.username = null;
  }

  nameWithTitle() { return this.name; }
}
