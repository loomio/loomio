class DiyGroupMigration
  EXISTING_SUBGROUP_MAP = {
    "6B9n1Eeb": "DIY Space For London outreach",
    "4C91yER6": "DIY Space For London outreach",
    "E7cTFakG": "DIY Space For London events",
    "10V4SJxb": "DIY Space For London events",
    "mGtoJrZ7": "DIY Space For London events",
    "uBldO264": "DIY Space For London planning, improving and organisation",
    "IrlCX3wh": "DIY Space For London planning, improving and organisation",
    "eUXp9Efb": "DIY Space For London planning, improving and organisation",
    "0ZOVjnYG": "DIY Space For London archive",
    "zn82PUNT": "DIY Space For London archive",
    "qkMlNVu7": "DIY Space For London archive",
    "p2Tktvub": "DIY Space For London archive",
    "WoNbAEru": "DIY Space For London archive",
    "VFHDLBl4": "DIY Space For London archive"
  }
  EXISTING_PARENT_GROUP_MAP = {
    "HRsK0g3o": "DIY Space For London outreach",
    "eSQZV9Ki": "DIY Space For London members",
    "h683sEGf": "DIY Space For London members",
    "CvpijZoO": "DIY Space For London members",
    "vk3NdUK2": "DIY Space For London events",
    "By12E906": "DIY Space For London events",
    "10V4SJxb": "DIY Space For London events",
    "15ZypFbo": "DIY Space For London events",
    "UcRK0HxM": "DIY Space For London making and mending",
    "lZeNisxb": "DIY Space For London making and mending",
    "ENGC0pai": "DIY Space For London making and mending",
    "9eTqkZ8l": "DIY Space For London planning, improving and organisation",
    "Hqr7MeQ2": "DIY Space For London planning, improving and organisation",
    "EL61V28O": "DIY Space For London planning, improving and organisation",
    "08WfiZjm": "DIY Space For London archive",
    "tMishJDw": "DIY Space For London archive",
    "I6aoNOSp": "DIY Space For London archive"
  }

  def self.perform!
    # Move existing subgroups to be subgroups of new parent groups
    EXISTING_SUBGROUP_MAP.each     { |key, value| move_group(key, value) }

    # Move existing parents to be subgroups of new parent groups
    EXISTING_PARENT_GROUP_MAP.each { |key, value| move_group(key, value) }

    Group.where(name: EXISTING_PARENT_GROUP_MAP.values, creator: User.helper_bot).pluck(:key)
  end

  def self.move_group(key, name)
    group  = Group.find_by(key: key)
    parent = Group.find_or_create_by(name: name, creator: User.helper_bot)

    group.update(subscription: nil, parent: parent)
    group.reload.memberships.where.not(user_id: parent.member_ids).active.each do |membership|
      if membership.admin
        parent.add_admin!(membership.user)
      else
        parent.add_member!(membership.user)
      end
    end
  end
end
