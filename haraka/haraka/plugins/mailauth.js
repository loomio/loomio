'use strict';

const mailauth = require('haraka-plugin-mailauth');
const { authenticate } = require('mailauth');
const { PassThrough } = require('node:stream');
const { readFileSync } = require('node:fs');
const { createPrivateKey } = require('node:crypto');

Object.assign(exports, mailauth);

exports.register = function () {
  mailauth.register.call(this);
  if (process.env.LOOMIO_MAIL_FORWARD_ARC_KEY_PATH) {
    const selector = process.env.LOOMIO_MAIL_FORWARD_ARC_SELECTOR;
    if (!selector || !/^[a-z0-9_-]+(?:\.[a-z0-9_-]+)*$/i.test(selector)) {
      throw new Error('A valid LOOMIO_MAIL_FORWARD_ARC_SELECTOR is required');
    }
    const privateKey = readFileSync(process.env.LOOMIO_MAIL_FORWARD_ARC_KEY_PATH);
    createPrivateKey(privateKey); // Fail startup on an unusable signing key.
    this.forward_seal = {signingDomain: process.env.REPLY_HOSTNAME, selector, privateKey};
  }
};

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

  const forwarding = transaction.notes.loomio_mail_route === 'forward';
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
    seal: forwarding ? this.forward_seal : undefined,
  }).then((result) => {
    // Rails holds messages on explicit authentication failures. An omitted
    // DMARC result for an invalid author must not become an apparent success.
    if (result.dmarcSkipReason) {
      result.dmarc = {
        status: { result: 'fail' },
        info: 'dmarc=fail (invalid From header)',
      };
    }
    // Keep private signing material out of transaction notes, which Haraka
    // serializes into the outbound queue alongside the message.
    const dkim = {...result.dkim};
    delete dkim.seal;
    transaction.notes.mailauth = { sender, ...result, dkim };

    if (forwarding && this.forward_seal) {
      const arcHeaders = result.headers.match(/^ARC-(?:Seal|Message-Signature|Authentication-Results):[^\r\n]*(?:\r?\n[ \t][^\r\n]*)*/gmi) || [];
      if (result.arc.sealErrors?.length) throw new Error('Unable to seal forwarded message');
      for (const header of arcHeaders.reverse()) {
        const separator = header.indexOf(':');
        transaction.add_leading_header(header.slice(0, separator), header.slice(separator + 1).trim());
      }
    }

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
    if (forwarding) throw error;
  }).then(() => next(), () => next(DENYSOFT, 'Email authentication unavailable; retry later'));

  transaction.message_stream.pipe(stream, { line_endings: '\r\n' });
};
