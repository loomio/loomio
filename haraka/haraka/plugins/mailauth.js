'use strict';

const mailauth = require('haraka-plugin-mailauth');

Object.assign(exports, mailauth);

// haraka-plugin-mailauth 1.1.1 expects the legacy Address#address() API,
// while Haraka 3.3 supplies Address#address as a string.
exports.hook_mail = function (next, connection, params) {
  const sender = params[0];
  if (!sender || typeof sender.address === 'function') {
    return mailauth.hook_mail.call(this, next, connection, params);
  }

  const senderCompatible = Object.create(sender);
  Object.defineProperty(senderCompatible, 'address', {
    value: () => sender.address,
  });
  return mailauth.hook_mail.call(this, next, connection, [senderCompatible, ...params.slice(1)]);
};
