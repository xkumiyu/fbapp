class CreateFbpages < ActiveRecord::Migration
  def change
    create_table :fbpages do |t|
      t.string :pid
      t.string :name

      t.timestamps
    end
  end
end
