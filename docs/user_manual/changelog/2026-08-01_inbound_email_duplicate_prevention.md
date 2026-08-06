# Prevent duplicate threads from retried email

When a mail server retries delivery of the same message, Loomio now recognises
its Message-ID and processes it only once. A retry no longer creates another
thread or forwards another copy to a configured staff mailbox.
