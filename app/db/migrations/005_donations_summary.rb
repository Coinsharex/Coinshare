# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:request_donations_details) do
      primary_key :id
      foreign_key :request_id

      Integer     :count, default: 0 # Amount of users donated
      Integer     :amount, default: 0 # Total of donations' sum
    end
  end
end
