# This migration comes from easy_rails_authentication_engine (originally 20120904133320)
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.boolean :admin

      t.timestamps
    end
  end
end
