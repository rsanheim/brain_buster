class BrainBusterMigrationGenerator < Rails::Generator::NamedBase
    attr_reader :migration_table_name
    def initialize(runtime_args, runtime_options = {})
      @migration_table_name = 'brain_busters'.tableize
      runtime_args << 'add_brain_buster' if runtime_args.empty?
      super
    end

    def manifest
      record do |m|
        m.migration_template 'migration.rb', 'db/migrate'
      end
    end
  end
