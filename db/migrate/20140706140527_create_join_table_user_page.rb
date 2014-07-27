class CreateJoinTableUserPage < ActiveRecord::Migration
  def change
    create_join_table :users, :pages do |t|
      # t.index [:user_id, :page_id]
      # t.index [:page_id, :user_id]
    end
  end
end
