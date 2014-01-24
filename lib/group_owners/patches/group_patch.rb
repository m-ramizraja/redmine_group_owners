module GroupOwners
  module Patches
    module GroupPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          has_many :group_owners, :dependent => :destroy
          has_many :owners, :through => :group_owners, :source => :user
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
