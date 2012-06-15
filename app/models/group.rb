class Group < ActiveRecord::Base

  belongs_to :offer

  has_one :allocation_tag
  has_one :curriculum_unit, :through => :offer
  has_one :course, :through => :offer

  has_many :users, :through => :allocation_tag
  has_many :logs
  has_many :assignments, :through => :allocation_tag

  def code_semester
    "#{code} - #{offer.semester}"
  end
  
  def self.find_all_by_curriculum_unit_id_and_user_id(curriculum_unit_id, user_id)
    CurriculumUnit.find(curriculum_unit_id).groups.where(["groups.id IN (?)", User.find(user_id).groups.map(&:id)])
  end

end
