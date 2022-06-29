# frozen_string_literal: true

class ChangeOffencesFilesToRepositoryCheck < ActiveRecord::Migration[6.1]
  def change
    change_column_null(:repository_checks, :passed, true)
    change_column_default(:repository_checks, :passed, from: false, to: nil)

    change_column_default(:repository_checks, :aasm_state, from: 'created', to: 'pending')

    change_column_null(:repository_checks, :offences_files, true)
    change_column_default(:repository_checks, :offences_files, from: [], to: nil)

    change_column_null(:repository_checks, :offences_amount, true)
    change_column_default(:repository_checks, :offences_amount, from: 0, to: nil)
  end
end
