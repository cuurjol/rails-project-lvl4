# frozen_string_literal: true

class User < ApplicationRecord
  has_many :repositories, dependent: :destroy

  validates :email, presence: true, uniqueness: true

  def self.update_or_create_with_omniauth(auth)
    params = { email: auth.info.email.downcase, nickname: auth.info.nickname, token: auth.credentials.token }
    user = User.find_by(email: params[:email])
    user.present? ? User.update(user.id, params) : User.create(params)
  end
end
