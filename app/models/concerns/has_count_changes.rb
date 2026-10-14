module HasCountChanges
  # Count callbacks run inside the write transaction. Describe creation,
  # editing and deletion as the same change: stored state -> new state.
  # Read saved_changes rather than retaining snapshots between saves, so
  # retries after a rollback cannot reuse an earlier contribution.
  def count_states
    if destroyed?
      [attributes.merge(attributes_in_database), nil]
    elsif previously_new_record?
      [nil, attributes]
    else
      [attributes.merge(saved_changes.transform_values(&:first)), attributes]
    end
  end
  private :count_states
end
