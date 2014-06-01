class AddColumnUsers < ActiveRecord::Migration
  def change
    add_column :users, :data, :string
  end
end
