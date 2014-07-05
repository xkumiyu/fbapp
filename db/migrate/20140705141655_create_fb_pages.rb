class CreateFbPages < ActiveRecord::Migration
  def change
    create_table :fb_pages do |t|
      t.integer :fb_user_id
      
      t.integer :pid
      t.string  :name

      t.timestamps
    end
  end
end
