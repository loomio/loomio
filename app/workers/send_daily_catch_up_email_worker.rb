# Compatibility for jobs queued before the digest terminology rename.
class SendDailyCatchUpEmailWorker < SendDigestEmailWorker
end
