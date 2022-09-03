# frozen_string_literal: true

require 'json'
require 'sequel'

module Coinbase
  # Models a secret request
  class Request < Sequel::Model
    # many_to_one: requestor
    ### THIS IS TEMPORARY
    one_to_many :donations
    plugin :association_dependencies, donations: :destroy

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :reason, :amount, :active

    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'request',
            attributes: {
              id:,
              reason:,
              amount:,
              active:
            }
          }
        }, options
      )
    end
  end
end
