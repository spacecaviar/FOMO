class CreateRadius < ActiveRecord::Migration
  def change
    create_table :radius do |t|
    	t.integer :radius
      t.timestamps
    end
  end
end
