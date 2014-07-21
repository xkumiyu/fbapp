class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.string :name
      t.string :token

      t.string  :image_url
      t.date    :birthday
      t.string  :gender
      t.string  :quotes

      t.timestamps
    end
  end
end
