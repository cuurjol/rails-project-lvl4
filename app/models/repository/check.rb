# frozen_string_literal: true

class Repository
  class Check < ApplicationRecord
    include AASM

    aasm do
      state :pending, initial: true
      state :finished, :failure

      event :finish do
        transitions from: :pending, to: :finished
      end

      event :fail do
        transitions from: :pending, to: :failure
      end
    end

    belongs_to :repository
  end
end
