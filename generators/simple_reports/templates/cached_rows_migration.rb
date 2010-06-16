class CreateCachedRows < ActiveRecord::Migration
  def self.up
    create_table :cached_rows do |t|
      t.string :table_key
      t.string :row_key
      t.text :data
      t.text :format
      t.text :row_format
      t.timestamps
    end

    add_index :cached_rows, [:table_key, :row_key], :unique => true
  end

  def self.down
    remove_index :cached_rows, :column => [:table_key, :row_key]
    drop_table :cached_rows
  end
end
