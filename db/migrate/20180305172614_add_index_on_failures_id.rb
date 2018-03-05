class AddIndexOnFailuresId < ActiveRecord::Migration[5.1]
  def change
    add_index :failures, %i[id]
  end
end
