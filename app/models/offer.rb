class Offer < ActiveRecord::Base
  include Taggable

  belongs_to :course
  belongs_to :curriculum_unit
  belongs_to :semester

  belongs_to :period_schedule,      class_name: "Schedule", foreign_key: "offer_schedule_id"
  belongs_to :enrollment_schedule,  class_name: "Schedule", foreign_key: "enrollment_schedule_id"

  has_many :groups
  has_many :academic_allocations, through: :allocation_tag
  has_many :lesson_modules,       through: :academic_allocations, source: :academic_tool, source_type: "LessonModule"
  has_many :assignments,          through: :academic_allocations, source: :academic_tool, source_type: "Assignment"

  after_create :set_default_lesson_module # modulo default da oferta

  after_destroy { |record|
    record.period_schedule.destroy if record.period_schedule.try(:can_destroy?)
    record.enrollment_schedule.destroy if record.enrollment_schedule.try(:can_destroy?)
  }

  validates :course, presence: true, if: "curriculum_unit.nil?"
  validates :curriculum_unit, presence: true, if: "course.nil?"
  validates :semester, presence: true

  validate :define_curriculum_unit, if: "!course.nil? && type_id == 3"
  validate :check_period, :must_be_unique

  accepts_nested_attributes_for :period_schedule, :enrollment_schedule

  attr_accessible :period_schedule_attributes, :enrollment_schedule_attributes, :curriculum_unit_id, :course_id, :semester_id
  attr_accessor :type_id

  def must_be_unique
    equal_offers = Offer.find_all_by_course_id_and_curriculum_unit_id_and_semester_id(course_id, curriculum_unit_id, semester_id)
    errors_to = (type_id == 3 ? :course : :curriculum_unit_id)
    errors.add(errors_to, I18n.t(:already_exist, scope: [:offers, :error])) if (@new_record and equal_offers.size > 0) or ((not equal_offers.empty?) and equal_offers.first.try(:id) != self.id)
  end

  def define_curriculum_unit
    course_name = Course.find(course_id).try(:name)
    curriculum_unit = CurriculumUnit.find_by_name(course_name)
    self.curriculum_unit_id = curriculum_unit.try(:id)
  end

  def check_period
    self.period_schedule.check_end_date = true if period_schedule and period_schedule.start_date
    self.period_schedule.verify_current_date = true if period_schedule
    self.enrollment_schedule.verify_current_date = true if enrollment_schedule
  end

  def lower_associated_objects
    groups
  end

  def set_default_lesson_module
    create_default_lesson_module(I18n.t(:general_of_offer, scope: :lesson_modules))
  end

  ## datas da oferta

  def start_date
    (period_schedule.try(:start_date) || semester.offer_schedule.start_date).to_date
  end

  def end_date
    (period_schedule.try(:end_date) || semester.offer_schedule.end_date).to_date
  end

  ## datas para matricula

  def enrollment_start_date
    enrollment_schedule.try(:start_date) || semester.enrollment_schedule.start_date
  end

  def enrollment_end_date
    # a oferta pode ou nao ter uma data final para periodo de matricula
    if enrollment_schedule_id.nil? # se o periodo de matricula na oferta for nulo
      semester.enrollment_schedule.end_date # o periodo no semestre será utilizado
    else
      enrollment_schedule.end_date
    end
  end

  def enrollment_period
    [enrollment_start_date, enrollment_end_date]
  end

  def self.currents(year = nil)
    unless year # se o ano passado for nil, pega os semestres do ano corrente em endiante
      self.joins(:period_schedule).where("schedules.end_date >= ?", Date.parse("#{Date.today.year}-01-01"))
    else # se foi definido, pega apenas daquele ano
      first_day_of_year, last_day_of_year = Date.parse("#{year}-01-01"), Date.parse("#{year}-12-31")
      self.joins(:period_schedule).where("(schedules.end_date BETWEEN ? AND ?) OR (schedules.start_date BETWEEN ? AND ?)", first_day_of_year, last_day_of_year, first_day_of_year, last_day_of_year)
    end
  end

  def has_any_lower_association?
    self.groups.count > 0
  end

  def info
    [course.try(:name), curriculum_unit.try(:name), semester.name].compact.join(" - ")
  end

end
