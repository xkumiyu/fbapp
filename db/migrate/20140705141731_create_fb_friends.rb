class CreateFbFriends < ActiveRecord::Migration
  def change
    create_table :fb_friends do |t|
      t.integer :fb_user_id
      t.integer :fb_friend_id

      t.timestamps
    end
  end
end
