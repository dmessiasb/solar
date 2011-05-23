class LessonsController < ApplicationController

  include LessonHelper

  #  load_and_authorize_resource
  before_filter :require_user, :only => [:list, :show]

  before_filter :curriculum_data, :only => [:list, :show, :show_header, :show_content]

  load_and_authorize_resource

  def show
    render :layout => 'lesson_frame'
  end
  def show_header
    render :layout => 'lesson'
  end
  def show_content
    render :layout => 'lesson'
  end

  def list
    
    # recebe id da aula para exibicao
    @lesson = params[:lesson_id].nil? ? nil : Lesson.find(params[:lesson_id])

    # pegando dados da sessao e nao da url
    groups_id = session[:opened_tabs][session[:active_tab]]["groups_id"]
    offers_id = session[:opened_tabs][session[:active_tab]]["offers_id"]

    # retorna aulas
    @lessons = return_lessons_to_open(offers_id, groups_id)

    # guarda lista de aulas para navegacao
    session[:lessons] = @lessons

  end

  private

  def curriculum_data
    if (params[:id])
      # localiza unidade curricular
      @curriculum_unit = CurriculumUnit.find(params[:id])
    end
  end

end