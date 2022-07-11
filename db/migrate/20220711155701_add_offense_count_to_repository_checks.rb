# frozen_string_literal: true

class AddOffenseCountToRepositoryChecks < ActiveRecord::Migration[6.1]
  def change
    add_column :repository_checks, :offense_count, :integer
  end
end
