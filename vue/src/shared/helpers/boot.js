import RestfulClient from '@/shared/record_store/restful_client';
import AppConfig from '@/shared/services/app_config';
import Records from '@/shared/services/records';
import { forEach, snakeCase } from 'lodash-es';
import { merge } from 'lodash-es';
import { bootData } from '@/shared/services/initial_data';

export default function(callback) {
  const client = new RestfulClient('boot');
  (bootData ? Promise.resolve(bootData) : client.get('site')).then(function(appConfig) {
    merge(AppConfig, appConfig)

    // Some browsers report Etc/Unknown. Validate the detected zone before
    // date formatting and profile autodetection use it.
    try {
      const timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC';
      new Intl.DateTimeFormat(undefined, {timeZone});
      AppConfig.timeZone = timeZone;
    } catch (error) {
      if (!(error instanceof RangeError)) { throw error; }
      AppConfig.timeZone = 'UTC';
    }

    forEach(Records, function(recordInterface, k) {
      const model = recordInterface.model
      if (model && appConfig.permittedParams[snakeCase(model.singular)]) {
        model.serializableAttributes = appConfig.permittedParams[snakeCase(model.singular)];
      }
    });

    return callback(appConfig);
  });
};
