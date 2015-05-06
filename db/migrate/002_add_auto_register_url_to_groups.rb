class AddAutoRegisterUrlToGroups < ActiveRecord::Migration
  def change
    add_column Group.table_name.to_sym, :auto_register_url, :string
  end
end
