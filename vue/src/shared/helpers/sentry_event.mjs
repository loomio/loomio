const isUnhandledRejection = event => event.exception?.values?.some(value =>
  value.mechanism?.handled === false && value.mechanism?.type?.includes('unhandledrejection')
);

export const beforeSend = (event, hint = {}) => {
  const error = hint.originalException;
  if (!error?.restfulClientError) { return event; }

  if (error.status === 401 && isUnhandledRejection(event)) {
    return null;
  }

  event.tags = Object.assign({}, event.tags, {
    http_method: error.httpMethod,
    http_resource: error.httpResource,
    http_status: String(error.status)
  });
  event.fingerprint = ['restful-client', String(error.status), error.httpResource];
  return event;
};
