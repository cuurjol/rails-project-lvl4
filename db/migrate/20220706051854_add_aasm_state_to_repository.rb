# frozen_string_literal: true

class AddAasmStateToRepository < ActiveRecord::Migration[6.1]
  def change
    add_column(:repositories, :aasm_state, :string, null: false, default: 'fetching')
  end
end
