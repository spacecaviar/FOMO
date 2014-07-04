class ColumnCountType < ActiveRecord::Migration
  def change
  	change_column Count ,:count ,:integer,:default => 0
  end
end
