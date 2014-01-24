module GroupOwners
  module Patches
    module GroupsHelperPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          alias_method_chain :group_settings_tabs, :owner
        end
      end

      module InstanceMethods
        def group_settings_tabs_with_owner
          tabs = [{:name => 'general', :partial => 'groups/general', :label => :label_general},
                  {:name => 'users', :partial => 'groups/users', :label => :label_user_plural},
          ]
          tabs << {:name => 'memberships', :partial => 'groups/memberships', :label => :label_project_plural} << {:name => 'owners', :partial => 'groups/owners', :label => :label_owner_plural} if User.current.admin?
          tabs
        end

        def render_principals_for_new_group_owners(group)
          scope = User.active.sorted.not_owner(group).like(params[:q])
          principal_count = scope.count
          principal_pages = Redmine::Pagination::Paginator.new principal_count, 100, params['page']
          principals = scope.offset(principal_pages.offset).limit(principal_pages.per_page).all

          s = content_tag('div', principals_check_box_tags('user_ids[]', principals), :id => 'principals')

          links = pagination_links_full(principal_pages, principal_count, :per_page_links => false) {|text, parameters, options|
            link_to text, autocomplete_for_owner_group_path(group, parameters.merge(:q => params[:q], :format => 'js')), :remote => true
          }

          s + content_tag('p', links, :class => 'pagination')
        end

      end
    end
  end
end

unless GroupsHelper.included_modules.include?(GroupOwners::Patches::GroupsHelperPatch)
  GroupsHelper.send(:include, GroupOwners::Patches::GroupsHelperPatch)
end