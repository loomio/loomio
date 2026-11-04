# Production email feedback samples

These fixtures were derived from real Amazon SES reports retained in production Action Mailbox on 21 October 2026. They preserve the outer MIME types, report fields and their order, recipient field syntax, status codes, transfer encodings, and the trusted relay's authentication-result format. All three reports include the original message as a `message/rfc822` part without an attachment filename.

- `ses_hard_bounce.eml`: failed delivery with DSN status `5.1.1`.
- `ses_transient_failure.eml`: failed delivery with diagnostic `550 4.4.7` and DSN status `4.4.7`; an SMTP `550` alone must not turn this report into a permanent address block.
- `ses_complaint.eml`: an ARF `abuse` report with a bare email address in `Original-Rcpt-To` and the SES-assigned Message-ID in the attached original message.

Anonymization took place on the production server before extraction. Customer names, addresses, subjects, message content, reply tokens, message IDs, MIME boundary IDs, dates, network addresses and diagnostic prose were removed or replaced with reserved test values. The original message body was replaced with plain text; provider sender domains and relevant authentication syntax remain.

The mailbox tests consume the trusted `Authentication-Results` metadata produced by the relay. These anonymized messages cannot validate the original DKIM signatures. Haraka's authentication tests exercise signature verification separately; a live SES simulator test is still needed to verify the deployed SMTP and feedback route end to end.
