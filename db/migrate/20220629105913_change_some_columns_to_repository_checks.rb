# frozen_string_literal: true

class ChangeSomeColumnsToRepositoryChecks < ActiveRecord::Migration[6.1]
  def change
    change_column_null(:repository_checks, :passed, true)
    change_column_default(:repository_checks, :passed, from: false, to: nil)

    change_column_default(:repository_checks, :aasm_state, from: 'created', to: 'pending')

    rename_column(:repository_checks, :offences_files, :offense_files)
    change_column_null(:repository_checks, :offense_files, true)
    change_column_default(:repository_checks, :offense_files, from: [], to: nil)

    remove_column(:repository_checks, :offences_amount, :integer)
  end
end
