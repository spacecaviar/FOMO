class CreateLayouts < ActiveRecord::Migration
  def change
    create_table :layouts do |t|
    	t.string :layouts
      t.timestamps
    end
  end
end
