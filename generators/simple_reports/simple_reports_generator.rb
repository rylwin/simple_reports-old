class SimpleReportsGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.migration_template "cached_rows_migration.rb", "db/migrate", :migration_file_name => 'create_cached_rows'
    end
  end
end
