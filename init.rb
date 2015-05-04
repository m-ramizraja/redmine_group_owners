require 'group_owners_patches'
Redmine::Plugin.register :redmine_group_owners do
  name 'Redmine Group Owners plugin'
  author 'Ramiz Raja'
  description 'This is a plugin for Redmine to allow admins to add owners for a group to manage it.'
  version '2.0.0'
  url 'http://www.redmine.org/plugins/redmine_group_owners'
  author_url 'http://www.linkedin.com/in/ramizraja'

  menu(:top_menu, :groups, { :controller => 'groups', :action => 'index' }, :caption => :label_group_plural, :after => :projects, :if => Proc.new {User.current.logged? && User.current.owned_groups.any?})
end
