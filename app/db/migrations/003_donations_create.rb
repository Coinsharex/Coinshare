# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:donations) do
      primary_key :id
      # TEMPORARY
      foreign_key :donor_id, :accounts

      Integer     :amount, null: false
      String      :identifier, null: false, unique: true
      String      :comment
      # String      :currency
      TrueClass   :anonymous, default: false

      # ...

      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end
