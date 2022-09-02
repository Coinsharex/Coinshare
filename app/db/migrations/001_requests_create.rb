# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:requests) do
      primary_key :id

      String    :reason, null: false
      String    :amount, null: false
      TrueClass :active, default: true

      DateTime  :created_at
      DateTime  :updated_at
    end
  end
end
