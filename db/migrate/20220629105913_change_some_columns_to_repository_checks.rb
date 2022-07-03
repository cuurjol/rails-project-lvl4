# frozen_string_literal: true

class ChangeSomeColumnsToRepositoryChecks < ActiveRecord::Migration[6.1]
  def change
    change_column_null(:repository_checks, :passed, true)
    change_column_default(:repository_checks, :passed, from: false, to: nil)

    change_column_default(:repository_checks, :aasm_state, from: 'created', to: 'pending')

    rename_column(:repository_checks, :offences_files, :offenses_files)
    change_column_null(:repository_checks, :offenses_files, true)
    change_column_default(:repository_checks, :offenses_files, from: [], to: nil)

    rename_column(:repository_checks, :offences_amount, :offenses_amount)
    change_column_null(:repository_checks, :offenses_amount, true)
    change_column_default(:repository_checks, :offenses_amount, from: 0, to: nil)
  end
end
