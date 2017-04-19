class AddIndiciesToTraces < ActiveRecord::Migration[5.0]
  def change
    add_index :traces, :name

    add_index :traces, :start,
      name: 'index_traces_on_start_asc',
      order: {start: :asc},
      using: :btree

    add_index :traces, :start,
      name: 'index_traces_on_start_desc',
      order: {start: :desc},
      using: :btree
  end
end
