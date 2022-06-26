# frozen_string_literal: true

class CreateRepositoryChecks < ActiveRecord::Migration[6.1]
  def change
    create_table :repository_checks do |t|
      t.string :aasm_state, null: false, default: 'created'
      t.boolean :passed, null: false, default: false
      t.integer :offences_amount, null: false, default: 0
      t.json :offences_files, null: false, default: []
      t.string :commit_sha
      t.string :commit_url
      t.references :repository, null: false, foreign_key: true

      t.timestamps
    end
  end
end
