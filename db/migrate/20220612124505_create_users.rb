# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :nickname
      t.string :token

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
