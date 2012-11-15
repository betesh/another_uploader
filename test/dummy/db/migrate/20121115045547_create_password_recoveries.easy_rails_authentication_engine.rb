# This migration comes from easy_rails_authentication_engine (originally 20120914205956)
class CreatePasswordRecoveries < ActiveRecord::Migration
  def change
    create_table :password_recoveries do |t|
      t.integer :user_id
      t.string :reset_link

      t.timestamps
    end
    add_index :password_recoveries, :user_id, :unique => true
    add_index :password_recoveries, :reset_link, :unique => true
  end
end
