class MakeSubgroupsOfSecretGroupsSecret
  def self.now
    Group.where('parent_id IS NOT NULL').find_each do |group|
      if group.privacy != 'secret' && group.parent.privacy == 'secret'
        group.update_attributes(privacy: 'secret')
      end
    end
  end
end