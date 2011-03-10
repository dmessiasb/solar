class CreateTableEnrollment < ActiveRecord::Migration
  def self.up
    create_table :enrollments do |t|
      t.references :offers
      t.date    :start,    :null => false
      t.date    :end,      :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :enrollments
  end
end