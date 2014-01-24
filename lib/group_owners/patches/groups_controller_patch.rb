module GroupOwners
  module Patches
    module GroupsControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          skip_before_filter :require_admin, :only => [:index, :show, :new, :create, :edit, :update, :add_users, :remove_user, :autocomplete_for_user]
          before_filter :require_admin_or_owner, :only => [:index, :show, :new, :create, :edit, :update, :add_users, :remove_user, :autocomplete_for_user]
          layout :set_layout
          alias_method_chain :index, :owner
          alias_method_chain :create, :owner
          alias_method_chain :update, :owner
        end
      end

      module InstanceMethods
        def index_with_owner
          @groups = (User.current.admin? ? Group.sorted.all : User.current.owned_groups)

          respond_to do |format|
            format.html
            format.api
          end
        end

        def create_with_owner
          @group = Group.new(params[:group])
          respond_to do |format|
            if @group.save
              @group.owners << User.current unless User.current.admin?
              format.html {
                flash[:notice] = l(:notice_successful_create)
                redirect_to(params[:continue] ? new_group_path : groups_path)
              }
              format.api  { render :action => 'show', :status => :created, :location => group_url(@group) }
            else
              format.html { render :action => "new" }
              format.api  { render_validation_errors(@group) }
            end
          end
        end

        def update_with_owner
          @group.assign_attributes(params[:group])
          respond_to do |format|
            if @group.save
              flash[:notice] = l(:notice_successful_update)
              format.html { redirect_to(groups_path) }
              format.api  { render_api_ok }
            else
              format.html { render :action => "edit" }
              format.api  { render_validation_errors(@group) }
            end
          end
        end

        def add_owners
          @users = User.find_all_by_id(params[:user_id] || params[:user_ids])
          @group.owners << @users if request.post?
          respond_to do |format|
            format.html { redirect_to edit_group_path(@group, :tab => 'owners') }
            format.js
            format.api { render_api_ok }
          end
        end

        def remove_owner
          @group.owners.delete(User.find(params[:user_id])) if request.delete?
          respond_to do |format|
            format.html { redirect_to edit_group_path(@group, :tab => 'owners') }
            format.js
            format.api { render_api_ok }
          end
        end

        def autocomplete_for_owner
          respond_to do |format|
            format.js
          end
        end

        private
        def require_admin_or_owner
          return unless require_login
          if !User.current.admin? && !(['index', 'new', 'create'].include?(action_name) && User.current.owned_groups.any?) && !(['show', 'edit', 'update', 'add_users', 'remove_user', 'autocomplete_for_user'].include?(action_name) && User.current.owned_groups.include?(@group))
            render_403
            return false
          end
          true
        end

        def set_layout
          User.current.admin ? 'admin' : 'base'
        end

      end
    end
  end
end

unless GroupsController.included_modules.include?(GroupOwners::Patches::GroupsControllerPatch)
  GroupsController.send(:include, GroupOwners::Patches::GroupsControllerPatch)
end
