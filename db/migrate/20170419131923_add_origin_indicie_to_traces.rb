class AddOriginIndicieToTraces < ActiveRecord::Migration[5.0]
  def change
    add_index :traces, :origin_id
  end
end
