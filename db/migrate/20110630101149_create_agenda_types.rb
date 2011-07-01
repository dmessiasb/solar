class CreateAgendaTypes < ActiveRecord::Migration
  def self.up
    create_table :agenda_types do |t|
      t.string :event_type
    end
  end

  def self.down
    drop_table :agenda_types
  end
end