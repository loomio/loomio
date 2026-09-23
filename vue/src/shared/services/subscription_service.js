import AppConfig from '@/shared/services/app_config';
import { subscriptionManagementUrl, subscriptionUpgradeUrl } from '@/shared/helpers/subscription_routes.mjs';

export default class SubscriptionService {
  static upgradeUrl(group) {
    return subscriptionUpgradeUrl({
      baseUrl: AppConfig.baseUrl,
      loomioSubscriptions: AppConfig.features.app.loomio_subscriptions,
      groupId: group?.id
    });
  }

  static managementUrl(group) {
    return subscriptionManagementUrl({
      baseUrl: AppConfig.baseUrl,
      groupId: group.id
    });
  }
}
