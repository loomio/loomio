class VersionService

  def self.reduce(model:, index:)

    versions = model.versions

    versions[index].object_changes = versions.first(index+1).reduce({}) do |changes, version|
      # for each field, nil values become the latest value we changed to
      keys = model.class.always_versioned_fields;

      always_changes = keys.map do |k|
        existing = changes.dig(k, 1)
        [k, version.object_changes[k.to_s] || [existing, existing]]
      end.to_h
      
      version.object_changes.merge always_changes

    end

    versions[index]
  end

end
