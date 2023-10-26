/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let AnonymousUser;
import I18n from '@/i18n';
export default AnonymousUser = (function() {
  AnonymousUser = class AnonymousUser {
    static initClass() {
      this.singular = 'group';
      this.plural = 'groups';
    
      this.prototype.name = I18n.t('common.anonymous');
      this.prototype.username = null;
    }
    nameWithTitle() { return this.name; }
  };
  AnonymousUser.initClass();
  return AnonymousUser;
})();
