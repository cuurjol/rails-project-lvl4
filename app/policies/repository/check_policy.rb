# frozen_string_literal: true

class Repository
  class CheckPolicy < ApplicationPolicy
    def create?
      user.present?
    end

    def show?
      create? && record.repository.user == user
    end
  end
end
