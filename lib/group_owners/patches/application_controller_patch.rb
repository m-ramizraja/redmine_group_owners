module GroupOwners
  module Patches
    module ApplicationControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          after_filter :auto_register_to_groups
        end
      end

      module InstanceMethods
        def auto_register_to_groups
          if User.current.logged?
            Group.where.not(:auto_register_url => nil).each do |group|
              begin
                url_action = Rails.application.routes.recognize_path(group.auto_register_url)[:action]
                url_controller = Rails.application.routes.recognize_path(group.auto_register_url)[:controller]
                if params[:controller].eql?(url_controller) && params[:action].eql?(url_action) && request.host.downcase.eql?(URI.parse(group.auto_register_url).host.downcase)
                  group.users << User.current unless group.users.include?(User.current)
                end
              rescue ActionController::RoutingError
                next
              end
            end
          end
        end
      end
    end
  end
end

unless ApplicationController.included_modules.include?(GroupOwners::Patches::ApplicationControllerPatch)
  ApplicationController.send(:include, GroupOwners::Patches::ApplicationControllerPatch)
end