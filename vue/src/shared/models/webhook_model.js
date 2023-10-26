/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let WebhookModel;
import BaseModel from '@/shared/record_store/base_model';
import AppConfig from '@/shared/services/app_config';

export default WebhookModel = (function() {
  WebhookModel = class WebhookModel extends BaseModel {
    static initClass() {
      this.singular = 'webhook';
      this.plural = 'webhooks';
    }

    defaultValues() {
      return {
        name: null,
        url: null,
        format: 'markdown',
        eventKinds: [],
        permissions: [],
        includeBody: true,
        errors: {}
      };
    }

    relationships() {
      return this.belongsTo('group');
    }
  };
  WebhookModel.initClass();
  return WebhookModel;
})();
