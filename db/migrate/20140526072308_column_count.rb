class ColumnCount < ActiveRecord::Migration
  def change
  change_column Count ,:count ,:string,:default => 0
  end
end
