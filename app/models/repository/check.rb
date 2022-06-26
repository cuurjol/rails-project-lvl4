# frozen_string_literal: true

class Repository
  class Check < ApplicationRecord
    include AASM

    aasm do
      state :created, initial: true
      state :checking, :finished, :failure

      event :start do
        transitions from: %i[created failed], to: :checking
      end

      event :finish do
        transitions from: :checking, to: :finished
      end

      event :reject do
        transitions from: :checking, to: :failure
      end
    end

    belongs_to :repository

    def pending?
      created? || checking?
    end
  end
end
