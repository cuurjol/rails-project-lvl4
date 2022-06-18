# frozen_string_literal: true

class RepositoryPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def new?
    index?
  end

  def create?
    index?
  end

  def show?
    index? && record.user == user
  end

  def destroy?
    show?
  end

  def update_from_github?
    show?
  end
end
