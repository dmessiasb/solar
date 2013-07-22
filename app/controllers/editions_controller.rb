class EditionsController < ApplicationController

  authorize_resource :only => [:index]

  def index
  end

  def items
  	@allocation_tags_ids = params[:allocation_tags_ids] || []
    @selected_course     = @allocation_tags_ids.collect{|id| true if AllocationTag.find(id).course}.include?(true)
    @selected_offer      = @allocation_tags_ids.collect{|id| true if AllocationTag.find(id).offer}.include?(true)
    @selected_group      = @allocation_tags_ids.collect{|id| true if AllocationTag.find(id).group}.include?(true)
  	render :partial => "items"
  end

  # GET /editions/academic
  def academic
    @types = CurriculumUnitType.all
    @type  = params[:type_id]
  end

  def courses
    @type = CurriculumUnitType.find(params[:curriculum_unit_type_id])
    @courses = Course.all
  end

  def curriculum_units
    @type = CurriculumUnitType.find(params[:curriculum_unit_type_id])
    @curriculum_units = @type.curriculum_units
  end

  def semesters
    @periods = [["Ativo", "active"], ["Todos", "all"]]
    @periods += Schedule.joins(:semester_periods).map {|p| [p.start_date.year, p.end_date.year] }.flatten.uniq.sort! {|x,y| y <=> x} # desc

    @type = CurriculumUnitType.find(params[:curriculum_unit_type_id])
    @curriculum_units = @type.curriculum_units
    @courses = Course.all

    @semesters = Semester.all # deve pegar só os ativos
  end

  def groups
    @type = CurriculumUnitType.find(params[:curriculum_unit_type_id])
    @curriculum_units = @type.curriculum_units
    @courses = Course.all
    @semesters = Semester.all
    # @groups = []
  end

end
