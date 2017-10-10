# frozen_string_literal: true

class AddFailures < ActiveRecord::Migration[5.1]
  def change
    create_table :failures, id: :uuid do |t|
      t.string :type, null: false
      t.text   :text, null: false
      t.jsonb  :stacktrace, null: false

      t.uuid :trace_id, null: false
      t.uuid :platform_id, null: false

      t.timestamps
    end
  end
end
