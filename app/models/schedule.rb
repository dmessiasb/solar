class Schedule < ActiveRecord::Base
  has_many :discussions
  has_many :lessons
  has_many :schedule_events
  has_many :assignments
  has_many :chat_rooms
  has_many :notifications

  has_many :offer_periods, class_name: "Offer", foreign_key: "offer_schedule_id"
  has_many :offer_enrollments, class_name: "Offer", foreign_key: "enrollment_schedule_id"

  has_many :semester_periods, class_name: "Semester", foreign_key: "offer_schedule_id"
  has_many :semester_enrollments, class_name: "Semester", foreign_key: "enrollment_schedule_id"

  validates :start_date, presence: true
  validates :end_date, presence: true, if: "check_end_date"

  validate :start_date_before_end_date
  validate :verify_by_current_date, if: "verify_current_date" # mudar nome

  before_destroy :can_destroy?

  # check_end_date: caso esteja setado, a data final será obrigatória / verify_current_date: verifica se o período é válido dada a data/ano atual
  attr_accessor :check_end_date, :verify_current_date

  def start_date_before_end_date
    unless start_date.nil? or end_date.nil?
      errors.add(:start_date, I18n.t(:range_date_error, :scope => [:discussions, :error])) if (start_date > end_date)
    end
  end

  def verify_by_current_date
    errors.add(:start_date, I18n.t(:current_year, :scope => [:schedules, :errors])) if not(start_date.nil?) and start_date_changed? and (start_date.year < Date.current.year)
    errors.add(:end_date, I18n.t(:current_date, :scope => [:schedules, :errors])) if not(end_date.nil?) and end_date_changed? and (end_date < Date.current)
  end

  def can_destroy?
    (discussions.empty? and lessons.empty? and assignments.empty? and schedule_events.empty? and offer_periods.empty? and offer_enrollments.empty? and semester_periods.empty? and semester_enrollments.empty?)
  end

end
