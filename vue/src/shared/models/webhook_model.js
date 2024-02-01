import BaseModel from '@/shared/record_store/base_model';
import AppConfig from '@/shared/services/app_config';

export default class WebhookModel extends BaseModel {
  static singular = 'webhook';
  static plural = 'webhooks';

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
    this.belongsTo('group');
  }
};
