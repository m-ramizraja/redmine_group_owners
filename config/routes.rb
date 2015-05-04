# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
resources :groups do
  member do
    get 'autocomplete_for_owner'
  end
end
get 'groups/:id/owners/new', :to => 'groups#new_owners', :id => /\d+/, :as => 'new_group_owners'
match 'groups/:id/owners', :controller => 'groups', :action => 'add_owners', :id => /\d+/, :via => :post, :as => 'group_owners'
match 'groups/:id/owners/:user_id', :controller => 'groups', :action => 'remove_owner', :id => /\d+/, :via => :delete, :as => 'group_owner'

