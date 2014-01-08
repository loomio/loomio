class DatabaseService

  def self.strip_private_data
    unless Rails.env.production?
      print "STRIPPING PRIVATE DATA\n"
      print "///////////////////////////////////////////////////"

      start_time = Time.now
      p start_time

      destroy_non_public_groups
      destroy_archved_groups
      sanitize_users
      destroy_invitations

      print "\n///////////////////////////////////////////////////\n"
      print "DONE\n"
    end
  end


  private

  def self.destroy_non_public_groups
    print "\n> Destroying non-public groups (#{Group.unscoped.where('privacy != ?', 'public').count}) & content \n"
    Group.unscoped.where('privacy != ?', 'public').find_each do |g|
      g.destroy
      print "\e[32m.\e[0m"
    end
  end

  def self.destroy_archved_groups
    print "\n> Destroying archived groups (#{Group.unscoped.where('archived_at IS NOT NULL').count}) & content\n"
    Group.unscoped.where('archived_at IS NOT NULL').find_each do |g|
      g.destroy
      print "\e[32m.\e[0m"
    end
  end

  def self.sanitize_users
    print "\n> Sanitizing user emails and passwords (#{User.unscoped.count})\n"
    User.unscoped.find_each do |user|
      user.update_attributes(email: "#{user.id}@fake.loomio.org", password: 'password')
      print "\e[32m.\e[0m"
    end
  end

  def self.destroy_invitations
    print "\n> Destroying ivitations (#{Invitation.unscoped.count})\n"
    Invitation.unscoped.find_each do |i|
      i.destroy
      print "\e[32m.\e[0m"
    end
  end


  def create_deletion_tree_for(model)
    relevant_reflections = model.reflections.values.select { |v| v.macro == :has_many && v.options[:dependent] == :destroy }

    return 'end' if relevant_reflections.empty?

    model_associations = {}
    relevant_reflections.each do |v|
      association_name = v.name
      association_model = (v.options[:class_name] || v.name.to_s.classify).constantize

      model_associations[association_name] = create_deletion_tree_for(association_model)
    end
    p model_associations
    model_associations
  end
  # tree = create_deletion_tree_for(Group)

end
