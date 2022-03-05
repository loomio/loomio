class SequenceService
  def self.seq_present?(key, id)
    ActiveRecord::Base.connection.execute(
    "SELECT 0 FROM partition_sequences where key = '#{key}' and id = #{id}"
    ).first.present?
  end

  def self.create_seq!(key, id, start)
    ActiveRecord::Base.connection.execute(
    "INSERT INTO partition_sequences (key, id, counter) VALUES ('#{key}', #{id}, #{start}) ON CONFLICT DO NOTHING"
    )
  end

  def self.next_seq!(key, id)
    ActiveRecord::Base.connection.execute(
    "UPDATE partition_sequences SET counter = counter + 1 WHERE key = '#{key}' AND id = #{id} RETURNING (counter)"
    )[0]["counter"]
  end

  def self.drop_seq!(key, id)
    ActiveRecord::Base.connection.execute(
    "DELETE FROM partition_sequences WHERE key = '#{key}' AND id = #{id}"
    )
  end
end
