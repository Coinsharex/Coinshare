# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module Coinbase
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :requests, class: :'Coinbase::Request', key: :requestor_id
    one_to_many :donations, class: :'Coinbase::Donation', key: :donor_id

    plugin :association_dependencies,
           requests: :destroy,
           donations: :destroy

    plugin :whitelist_security
    set_allowed_columns :first_name, :last_name, :email,
                        :password, :occupation, :university, :field_of_study, :study_level, :picture, :bio

    plugin :timestamps, update_on_create: true

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = Coinbase::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          attributes: {
            id:,
            first_name:,
            last_name:,
            email:,
            occupation:,
            university:,
            field_of_study:,
            study_level:,
            picture:,
            bio:
          }
        }, options
      )
    end
  end
end
