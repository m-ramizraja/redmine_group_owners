module GroupOwners
  module Patches
    module GroupPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.extend(ClassMethods)
        base.class_eval do
          unloadable
          has_many :group_owners, :dependent => :destroy
          has_many :owners, :through => :group_owners, :source => :user
          safe_attributes 'name',
                          'auto_register_url',
                          'user_ids',
                          'custom_field_values',
                          'custom_fields',
                          :if => lambda {|group, user| (user.admin? || (group.persisted? ? group.owners.include?(user) : user.owned_groups.any?)) && !group.builtin?}
        end
      end
      module InstanceMethods
      end
      module ClassMethods
        def add_user_to_group(user_id, group_id)
          user = User.find_by_id(user_id)
          group = Group.find_by_id(group_id)
          if user && group && (group.owners.include?(User.current)||User.current.admin?)
            group.users << user unless group.users.include?(user)
          end
        end

        def delete_user_from_group(user_id, group_id)
          user = User.find_by_id(user_id)
          group = Group.find_by_id(group_id)
          if user && group && (group.owners.include?(User.current)||User.current.admin?)
            group.users.delete(user) if group.users.include?(user)
          end
        end
      end
    end
  end
end

unless Group.included_modules.include?(GroupOwners::Patches::GroupPatch)
  Group.send(:include, GroupOwners::Patches::GroupPatch)
end
