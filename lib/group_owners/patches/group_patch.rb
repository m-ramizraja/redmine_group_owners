module GroupOwners
  module Patches
    module GroupPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          has_many :group_owners, :dependent => :destroy
          has_many :owners, :through => :group_owners, :source => :user
          safe_attributes 'name',
                          'user_ids',
                          'custom_field_values',
                          'custom_fields',
                          :if => lambda {|group, user| (user.admin? || (group.persisted? ? group.owners.include?(user) : user.owned_groups.any?)) && !group.builtin?}
        end
      end
      module InstanceMethods
      end
    end
  end
end

unless Group.included_modules.include?(GroupOwners::Patches::GroupPatch)
  Group.send(:include, GroupOwners::Patches::GroupPatch)
end
