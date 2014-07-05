class CreateFbUsers < ActiveRecord::Migration
  def change
    create_table :fb_users do |t|
      t.integer :user_id

      t.string  :uid
      t.string  :name
      t.string  :image_url
      t.date    :birthday
      t.string  :gender
      t.string  :quotes

      t.timestamps
    end
  end
end
