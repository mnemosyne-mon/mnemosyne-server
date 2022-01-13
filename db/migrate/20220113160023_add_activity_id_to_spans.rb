# frozen_string_literal: true

class AddActivityIdToSpans < ActiveRecord::Migration[6.1]
  def change
    add_column :spans, :activity_id, :uuid, index: true
  end
end
