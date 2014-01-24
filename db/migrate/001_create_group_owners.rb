class CreateGroupOwners < ActiveRecord::Migration
  def change
    create_table :group_owners do |t|
      t.integer :group_id, :null => false
      t.integer :user_id, :null => false

      t.timestamps
    end
  end
end
