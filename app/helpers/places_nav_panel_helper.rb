=begin

  = Listar apenas informações em que o usuário tem alguma ligação com permissão de edição
    - verificar em qual ponto da hierarquia o usuario tem permissao para visualizar
      - listar todas as informacoes abaixo desse ponto
        - uc, oferta, turma

TODO: 
	- remover o '/assets' dos caminhos de imagens
    - Ver necessidade de indexar no BD os campos de busca para melhorar a performance de tudo.
=end

module PlacesNavPanelHelper

  def places_nav_panel_helper
  
	selectedCourseName = ''
	selectedCourseValue = ''
	selectedSemesterName = ''
	selectedSemesterValue = ''
	selectedCurriculumUnitName = ''
	selectedCurriculumUnitValue = ''
	selectedGroupName = ''
	selectedGroupValue = ''
	
	selectedCourseName = params[:places_nav_panel_selectedCourseName] if params.include?(:places_nav_panel_selectedCourseName)
	selectedCourseValue = params[:places_nav_panel_selectedCourseValue] if params.include?(:places_nav_panel_selectedCourseValue)
	selectedSemesterName = params[:places_nav_panel_selectedSemesterName] if params.include?(:places_nav_panel_selectedSemesterName)
	selectedSemesterValue = params[:places_nav_panel_selectedSemesterValue] if params.include?(:places_nav_panel_selectedSemesterValue)
	selectedCurriculumUnitName = params[:places_nav_panel_selectedCurriculumUnitName] if params.include?(:places_nav_panel_selectedCurriculumUnitName)
	selectedCurriculumUnitValue = params[:places_nav_panel_selectedCurriculumUnitValue] if params.include?(:places_nav_panel_selectedCurriculumUnitValue)
	selectedGroupName = params[:places_nav_panel_selectedGroupName] if params.include?(:places_nav_panel_selectedGroupName)
	selectedGroupValue = params[:places_nav_panel_selectedGroupValue] if params.include?(:places_nav_panel_selectedGroupValue)
    
    raw %{
	#{ javascript_include_tag "places_nav_panel"}
	#{ javascript_include_tag "jquery.tokeninput.js"}
    #{ stylesheet_link_tag "places_nav_panel" }

	<script type="text/javascript">

		//Declarando caminhos para a busca do componente. Nao conseguimos colocar isso no javascript		
		var search_urls = {
			"course": "#{url_for :controller => :courses, :format => "json"}", 
			"semester": "#{url_for :controller => :offers, :action => "list", :format => "json"}", 
			"curriculumUnit": "#{url_for :controller => :offers, :action => "list", :format => "json"}",
			"group": "#{url_for :controller => :groups, :action => "list", :format => "json"}"
		};
		
		var controller_urls = {
			"course": "#{url_for :controller => :courses}",
			"curriculumUnit": "#{url_for :controller => :curriculum_units, :action => "new"}",
			"group": "#{url_for :controller => :groups}"
		}
		
		var hints = {
			"course": "#{I18n.t(:places_nav_panel_course_hint)}", 
			"semester": "#{I18n.t(:places_nav_panel_semester_hint)}", 
			"curriculumUnit": "#{I18n.t(:places_nav_panel_curriculum_unit_hint)}",
			"group": "#{I18n.t(:places_nav_panel_group_hint)}"
		};
		
		var messages = {
			"searching": "#{I18n.t(:places_nav_panel_searching_text)}", 
			"noResults": "#{I18n.t(:places_nav_panel_empty_text)}"
		};
		
		
		//Acao dos Botoes 
		function placesNavPanel_redirect(url){
			var strForm = '<form id="places_nav_panel_redirectionForm" style="display:none;" method="get">&nbsp;</form>';
				$('body').append(strForm);
				var $redirectionForm = $('#places_nav_panel_redirectionForm');
				$redirectionForm.attr('action',url);
				$redirectionForm.attr('method','get');
				$redirectionForm.append($('.placesNavPanel'));
				$redirectionForm.submit();
		}
		
		$(document).ready(function() { 
			$('#places_nav_panel_btManageCourses').click(function(){
				placesNavPanel_redirect(controller_urls["course"]);
			});
			$('#places_nav_panel_btManageCurriculumUnit').click(function(){
				showLightBoxURL(controller_urls["curriculumUnit"], 540, 605, true, 'Nova Unidade Curricular');
			});
			$('#places_nav_panel_btManageGroups').click(function(){
				placesNavPanel_redirect(controller_urls["group"]);
			});
		});
		
		
	</script>
	
	<div class="placesNavPanel">
		<div><span 
			class="label">#{t(:course)}:</span><input 
			type="text" id="places_nav_panel_txtCourse"/>
			<input id="places_nav_panel_btManageCourses" type="button" value="[Gerenciar]" class ="btn btn_main btShowMenu"/>
			<input type="hidden" id="places_nav_panel_selectedCourseName" name="places_nav_panel_selectedCourseName" value="#{selectedCourseName}"/>
			<input type="hidden" id="places_nav_panel_selectedCourseValue" name="places_nav_panel_selectedCourseValue" value="#{selectedCourseValue}"/>
		</div>
		<div><span 
			class="label">#{t(:semester_date)}:</span><input 
			type="text" id="places_nav_panel_txtSemester"/>
			<input id="places_nav_panel_btManageOfferBySemester" type="button" value="[Ofertar]" class ="btn btn_main btShowMenu"/>
			<input type="hidden" id="places_nav_panel_selectedSemesterName" name="places_nav_panel_selectedSemesterName" value="#{selectedSemesterName}"/>
			<input type="hidden" id="places_nav_panel_selectedSemesterValue" name="places_nav_panel_selectedSemesterValue" value="#{selectedSemesterValue}"/>
		</div>
		<div><span 
			class="label" style=";">#{t(:curriculum_unit)}:</span><input 
			type="text" id="places_nav_panel_txtCurriculumUnit"/>
			<input id="places_nav_panel_btManageCurriculumUnit" type="button" value="[Gerenciar]" class ="btn btn_main btShowMenu"/>
			<input id="places_nav_panel_btManageOfferByCurriculumUnit" type="button" value="[Ofertar]" class ="btn btn_main btShowMenu"/>
			<input type="hidden" id="places_nav_panel_selectedCurriculumUnitName" name="places_nav_panel_selectedCurriculumUnitName" value="#{selectedCurriculumUnitName}"/>
			<input type="hidden" id="places_nav_panel_selectedCurriculumUnitValue" name="places_nav_panel_selectedCurriculumUnitValue" value="#{selectedCurriculumUnitValue}"/>
		</div>
		<div><span 
			class="label">#{t(:group)}:</span><input 
			type="text" id="places_nav_panel_txtGroup"/>
			<input id="places_nav_panel_btManageGroups" type="button" value="[Gerenciar]" class ="btn btn_main btShowMenu"/>
			<input type="hidden" id="places_nav_panel_selectedGroupName" name="places_nav_panel_selectedGroupName" value="#{selectedGroupName}"/>
			<input type="hidden" id="places_nav_panel_selectedGroupValue" name="places_nav_panel_selectedGroupValue"value="#{selectedGroupValue}"/>
		</div>
	</div>
	
    }
  end

end
