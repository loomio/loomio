class StripPrivateData
  def self.go
    unless Rails.env.production?
      print "STRIPPING PRIVATE DATA\n"
      print "///////////////////////////////////////////////////"

      print "\n> Destroying non-public groups & content\n"
      Group.unscoped.where('privacy != ?', 'public').find_each do |g|
        g.destroy
        print "\e[32m.\e[0m"
      end

      print "\n> Destroying archived groups & content\n"
      Group.unscoped.where('archived_at IS NOT NULL').find_each do |g|
        g.destroy
        print "\e[32m.\e[0m"
      end

      print "\n> Sanitizing user emails and passwords\n"
      User.unscoped.find_each do |user|
        user.update_attributes(email: "#{user.id}@fake.loomio.org", password: 'password')
        print "\e[32m.\e[0m"
      end

      print "\n> Destroying ivitations\n"
      Invitation.unscoped.find_each do |i|
        i.destroy
        print "\e[32m.\e[0m"
      end

      print "\n///////////////////////////////////////////////////\n"
      print "DONE\n"
    end
  end

end
