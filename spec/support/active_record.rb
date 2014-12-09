require "active_record"


ActiveRecord::Base.establish_connection(:adapter => "sqlite3",
                                        :database => ":memory:")
ActiveRecord::Migration.create_table :records do |t|
  t.datetime :deleted_at
  t.timestamps
end
ActiveRecord::Migration.create_table :elements do |t|
  t.integer :record_id, index: true
  t.integer :has_one_element_record_id, index: true
  t.datetime :deleted_at
  t.timestamps
end

ActiveRecord::Migration.create_table :micro_elements do |t|
  t.integer :element_id, index: true
  t.datetime :deleted_at
  t.timestamps
end


ActiveRecord::Migration.create_table :non_dead_records do |t|
  t.integer :record_id, index: true
  t.timestamps
end

RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end


