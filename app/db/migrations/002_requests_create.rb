# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:requests) do
      primary_key :id
      foreign_key :requestor_id, :accounts

      String      :title, null: false
      String      :description, null: false
      Integer     :amount, null: false
      String      :location, null: false
      TrueClass   :active, default: true

      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end
