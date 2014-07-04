class CreateTimeintervals < ActiveRecord::Migration
  def change
    create_table :timeintervals do |t|
      t.integer :time_interval_mins
      t.timestamps
    end
  end
end
