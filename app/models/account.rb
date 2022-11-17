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
                        :password, :occupation, :university, :field_of_study, :study_level, :picture

    plugin :timestamps, update_on_create: true

    def self.create_google_account(google_account)
      create(first_name: google_account[:first_name],
             last_name: google_account[:last_name],
             email: google_account[:email],
             picture: google_account[:picture])
    end

    def transactions
      requests + donations
    end

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
            first_name:,
            last_name:,
            email:,
            occupation:,
            university:,
            field_of_study:,
            study_level:,
            picture:
          }
        }, options
      )
    end
  end
end
