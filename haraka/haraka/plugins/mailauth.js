'use strict';

const mailauth = require('haraka-plugin-mailauth');
const { authenticate } = require('mailauth');
const { PassThrough } = require('node:stream');

Object.assign(exports, mailauth);

// Keep SMTP envelope data until the complete message can be authenticated.
exports.hook_mail = function (next, connection, params) {
  if (!connection.transaction) return next();

  const sender = params[0];
  connection.transaction.notes.mailauth = {
    sender: typeof sender.address === 'function' ? sender.address() : sender.address,
  };
  next();
};

// Use Mailauth's combined API so DKIM parsing metadata reaches DMARC. The old
// plugin assembles these checks itself and drops the From-field validity data.
exports.hook_data_post = function (next, connection) {
  const transaction = connection.transaction;
  if (!transaction) return next();

  const sender = transaction.notes.mailauth.sender;
  const stream = new PassThrough();
  authenticate(stream, {
    sender,
    ip: connection.remote.ip,
    helo: connection.hello.host,
    mta: connection.local.host,
    resolver: this.resolver,
    maxResolveCount: this.cfg.dns?.maxLookups,
    minBitLength: this.cfg.minBitLength,
  }).then((result) => {
    // Rails holds messages on explicit authentication failures. An omitted
    // DMARC result for an invalid author must not become an apparent success.
    if (result.dmarcSkipReason) {
      result.dmarc = {
        status: { result: 'fail' },
        info: 'dmarc=fail (invalid From header)',
      };
    }
    transaction.notes.mailauth = { sender, ...result };

    if (result.spf.header) {
      const header = result.spf.header;
      transaction.add_leading_header('Received-SPF', header.substring(header.indexOf(':') + 1).trim());
    }

    const checks = result.dkim.results.map((check) => ['dkim', check]);
    for (const method of ['spf', 'arc', 'dmarc', 'bimi']) {
      if (result[method]) checks.push([method, result[method]]);
    }
    for (const [method, check] of checks) {
      this.mailauth_add_result(transaction, method, check.signingDomain || check.domain || check.status.header?.d, check.status.result);
      if (check.info) connection.auth_results(check.info);
    }
    transaction.remove_header('bimi-location');
    transaction.remove_header('bimi-indicator');
  }).catch((error) => {
    transaction.results.add(this, { err: 'mailauth' });
    this.logerror(error, this, connection);
  }).finally(next);

  transaction.message_stream.pipe(stream, { line_endings: '\r\n' });
};
