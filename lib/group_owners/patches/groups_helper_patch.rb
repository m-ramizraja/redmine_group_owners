module GroupOwners
  module Patches
    module GroupsHelperPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          alias_method_chain :group_settings_tabs, :owner
          alias_method_chain :render_principals_for_new_group_users, :owner
        end
      end

      module InstanceMethods
        def group_settings_tabs_with_owner(group)
          tabs = []
          tabs << {:name => 'general', :partial => 'groups/general', :label => :label_general}
          tabs << {:name => 'users', :partial => 'groups/users', :label => :label_user_plural} if group.givable?
          tabs << {:name => 'memberships', :partial => 'groups/memberships', :label => :label_project_plural} << {:name => 'owners', :partial => 'groups/owners', :label => :label_owner_plural} if User.current.admin?
          tabs << {:name => 'auto_register_url', :partial => 'groups/auto_register_url', :label => :label_auto_register_url} if group.givable?
          tabs
        end

        def render_principals_for_new_group_users_with_owner(group, limit=100)
          selected_group = Group.find_by_id(params[:group_id])
          scope = (selected_group ? User.active.sorted.in_group(selected_group).not_in_group(group).like(params[:q])  : User.active.sorted.not_in_group(group).like(params[:q]))
          principal_count = scope.count
          principal_pages = Redmine::Pagination::Paginator.new principal_count, limit, params['page']
          principals = scope.offset(principal_pages.offset).limit(principal_pages.per_page).to_a

          s = content_tag('div',
                          content_tag('div', principals_check_box_tags('user_ids[]', principals), :id => 'principals'),
                          :class => 'objects-selection'
          )

          links = pagination_links_full(principal_pages, principal_count, :per_page_links => false) {|text, parameters, options|
            link_to text, autocomplete_for_user_group_path(group, parameters.merge(:q => params[:q], :format => 'js')), :remote => true
          }

          s + content_tag('p', links, :class => 'pagination')
        end

        def render_principals_for_new_group_owners(group, limit=100)
          scope = User.active.sorted.not_owner(group).like(params[:q])
          principal_count = scope.count
          principal_pages = Redmine::Pagination::Paginator.new principal_count, limit, params['page']
          principals = scope.offset(principal_pages.offset).limit(principal_pages.per_page).to_a

          s = content_tag('div',
                          content_tag('div', principals_check_box_tags('user_ids[]', principals), :id => 'principals'),
                          :class => 'objects-selection'
          )

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