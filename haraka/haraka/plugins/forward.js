'use strict';

const { Address } = require('@haraka/email-address');

// Staff aliases use Haraka's durable outbound queue. Split SMTP transactions
// at RCPT time so a retry cannot forward staff mail twice after Rails fails.
exports.register = function () {
  this.load_forwarding_config();
  this.outbound = this.haraka_require('outbound');
  this.register_hook('rcpt', 'route_recipient', -10);
  this.register_hook('queue', 'queue_forward', -10);
};

exports.load_forwarding_config = function () {
  const rules = this.config.get('forwarding.json', 'json', () => this.load_forwarding_config());
  if (!rules || Array.isArray(rules) || typeof rules !== 'object') {
    throw new Error('forwarding.json must be an address-to-address object');
  }
  const forwardRules = new Map();
  const hostname = process.env.REPLY_HOSTNAME.toLowerCase();
  for (const [source, destination] of Object.entries(rules)) {
    const sourceAddress = source.includes('@') ? source : `${source}@${hostname}`;
    const destinationAddress = destination === '${SUPPORT_EMAIL}' ? process.env.SUPPORT_EMAIL : destination;
    const from = new Address(sourceAddress);
    const to = new Address(destinationAddress);
    if (from.address.toLowerCase() !== sourceAddress.toLowerCase() || from.host.toLowerCase() !== hostname ||
        !to.host || to.host.toLowerCase() === hostname || to.address !== destinationAddress) {
      throw new Error('Forwarding rules must map exact local addresses to external addresses');
    }
    forwardRules.set(from.address.toLowerCase(), to.address);
  }
  let forwardSender;
  if (forwardRules.size) {
    forwardSender = new Address(process.env.LOOMIO_MAIL_FORWARD_SENDER || `postmaster@${hostname}`);
    if (!forwardRules.has(forwardSender.address.toLowerCase())) {
      throw new Error('LOOMIO_MAIL_FORWARD_SENDER must be a monitored forwarding alias');
    }
  }
  this.forward_rules = forwardRules;
  this.forward_sender = forwardSender;
};

exports.route_recipient = function (next, connection, [recipient]) {
  if (recipient.host?.toLowerCase() !== process.env.REPLY_HOSTNAME.toLowerCase()) return next();

  const transaction = connection.transaction;
  const route = this.forward_rules.has(recipient.address.toLowerCase()) ? 'forward' : 'rails';
  if (transaction.notes.loomio_mail_route && transaction.notes.loomio_mail_route !== route) {
    return next(DENYSOFT, 'Separate staff and application recipients; retry this recipient');
  }
  transaction.notes.loomio_mail_route = route;
  if (route === 'forward') return next(OK);
  next();
};

exports.queue_forward = function (next, connection) {
  const transaction = connection.transaction;
  if (transaction.notes.loomio_mail_route !== 'forward') return next();

  const destinations = transaction.rcpt_to.map((recipient) => this.forward_rules.get(recipient.address.toLowerCase()));
  if (destinations.some((destination) => !destination)) {
    return next(DENYSOFT, 'Forwarding destination unavailable');
  }
  transaction.rcpt_to = [...new Set(destinations)].map((destination) => new Address(destination));
  // Keep From, Reply-To, Date, Message-ID and MIME content intact. Only the
  // SMTP envelope sender changes for SPF; failures reach a monitored alias.
  // Preserve null senders so failed delivery reports cannot cause bounce loops.
  if (transaction.mail_from.address) transaction.mail_from = this.forward_sender;
  this.outbound.send_trans_email(transaction, (status) => {
    if (status === OK) return next(OK, 'Forwarded message queued');
    next(DENYSOFT, 'Unable to queue forwarded message; retry later');
  });
};
