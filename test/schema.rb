ActiveRecord::Schema.define(:version => 0) do
  create_table "cached_rows", :force => true do |t|
    t.string   "table_key"
    t.string   "row_key"
    t.text   "data"
    t.text   "format"
    t.text   "row_format"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
end