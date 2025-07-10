import RestfulClient from '@/shared/record_store/restful_client';
import AppConfig from '@/shared/services/app_config';
import Records from '@/shared/services/records';
import { forEach, snakeCase } from 'lodash-es';
import { merge } from 'lodash-es';

export default function(callback) {
  const client = new RestfulClient('boot');
  client.get('site').then(function(appConfig) {
    merge(AppConfig, appConfig)

    AppConfig.timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;

    ['shortcut icon'].forEach(function(name) {
      const link = document.createElement('link');
      link.rel = name;
      link.href = appConfig.theme.icon_src;
      return document.getElementsByTagName('head')[0].appendChild(link);
    });

    forEach(Records, function(recordInterface, k) {
      const model = recordInterface.model
      if (model && appConfig.permittedParams[snakeCase(model.singular)]) {
        model.serializableAttributes = appConfig.permittedParams[snakeCase(model.singular)];
      }
    });

    return callback(appConfig);
  });
};
