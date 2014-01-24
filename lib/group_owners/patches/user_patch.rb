module GroupOwners
  module Patches
    module UserPatch
      def self.included(base)
        base.class_eval do
          unloadable
          has_many :group_owners, :dependent => :destroy
          has_many :owned_groups, :through => :group_owners, :source => :group
          scope :not_owner, lambda {|group|
            group_id = group.is_a?(Group) ? group.id : group.to_i
            where("#{User.table_name}.id NOT IN (SELECT gu.user_id FROM group_owners gu WHERE gu.group_id = ?)", group_id)
          }
        end
      end
    end
  end
end

unless User.included_modules.include?(GroupOwners::Patches::UserPatch)
  User.send(:include, GroupOwners::Patches::UserPatch)
end
