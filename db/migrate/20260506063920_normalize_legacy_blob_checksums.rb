class NormalizeLegacyBlobChecksums < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  # An earlier Paperclip→ActiveStorage migration stored S3 etags verbatim as
  # blob checksums. ActiveStorage expects base64-encoded MD5 (24 chars), so
  # the 32-char hex etags fail Downloader#verify_integrity_of, breaking
  # AnalyzeJob, variant generation, and any download path that opens the
  # blob. Normalize:
  #   * 32-char hex etag → base64 MD5 (the etag IS the file's MD5 for
  #     single-part uploads, just in the wrong encoding)
  #   * `HEX-N` multipart etag → flag blob `composed: true` so download
  #     skips integrity verification (the etag is not the file's MD5 and
  #     can't be recovered without re-downloading)
  # Also set `analyzed: true` so AnalyzeJob doesn't keep retrying on these
  # blobs (image dimensions are lost, but better than perpetual job retries).
  def up
    scope = ActiveStorage::Blob.where("checksum ~* ?", '^[a-f0-9]{32}(-[0-9]+)?$')
    total = scope.count
    say "Found #{total} legacy-checksum blob(s) to normalize"
    return if total.zero?

    fixed = 0
    scope.find_each(batch_size: 500) do |blob|
      normalize!(blob)
      fixed += 1
      say "  normalized #{fixed}/#{total}", true if (fixed % 1000).zero?
    end
    say "  normalized #{fixed} blob(s)", true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def normalize!(blob)
    return if blob.checksum.blank?

    changes = {}
    metadata = blob.metadata.is_a?(Hash) ? blob.metadata.dup : {}

    if blob.checksum.match?(/\A[a-f0-9]{32}\z/i)
      changes[:checksum] = Base64.strict_encode64([blob.checksum].pack('H*'))
    elsif blob.checksum.match?(/\A[a-f0-9]{32}-\d+\z/i)
      metadata['composed'] = true unless metadata['composed']
    end

    metadata['analyzed'] = true unless metadata['analyzed']
    changes[:metadata] = metadata if metadata != blob.metadata

    blob.update_columns(changes) if changes.any?
  end
end
