# frozen_string_literal: true

class CreateRepositories < ActiveRecord::Migration[6.1]
  def change
    create_table :repositories do |t|
      t.string :name
      t.string :full_name
      t.string :description
      t.string :language
      t.string :html_url
      t.integer :github_id, null: false
      t.datetime :github_created_at, precision: 6
      t.datetime :github_updated_at, precision: 6
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :repositories, :github_id, unique: true
  end
end
