require 'test_helper'

class CurriculumUnitsWithLessonsTest < ActionDispatch::IntegrationTest

  # para poder realizar o "login_as" sabendo que o sign_in do devise não funciona no teste de integração
  include Warden::Test::Helpers

  def setup
    login_as users(:aluno1), scope: :user

    @quimica_tab = add_tab_path(id: 3, context:2, allocation_tag_id: 13)
    @teoria_lite = add_tab_path(id: 2, context:2, allocation_tag_id: 12)
  end

  ##
  # Acessar aulas
  ##

  test "acessar aula tipo link como aluno" do
    get @quimica_tab

    get lesson_path(4)
    assert_response :success
  end

  test "acessar aula tipo arquivo como aluno" do
    get @teoria_lite

    get lesson_path(7)
    assert_response :success
  end

  test "nao acessar aula sem acessar unidade curricular primeiro" do
    get lesson_path(4)
    assert_response :not_found

    assert_equal response.body, I18n.t(:curriculum_unit_not_selected, scope: :lessons)
  end

end
