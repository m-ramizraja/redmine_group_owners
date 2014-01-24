#patches
Rails.configuration.to_prepare do
  require 'group_owners/patches/group_patch'
  require 'group_owners/patches/user_patch'
  require 'group_owners/patches/groups_helper_patch'
  require 'group_owners/patches/groups_controller_patch'
end
