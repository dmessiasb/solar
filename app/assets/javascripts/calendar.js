$(document).ready(function() {

  var date = new Date();
  var d = date.getDate();
  var m = date.getMonth();
  var y = date.getFullYear();

  var edition_param = $("#calendar").attr("data-edition");
  var ids_to_forms_param = $("#calendar").attr("data-ids");

  var lastView;

  // Sources para recuperar os eventos
  var fcSources = {
    calendar: {
                url: '/schedules/events',
                data: {
                  "allocation_tags_ids": $("#allocation_tags_ids").val(),
                  "all_groups_ids": $("#all_groups_ids").val()
                },
                textColor: 'black',
                ignoreTimezone: false
            },
    list: {
                url: '/schedules/events',
                data: {
                  "allocation_tags_ids": $("#allocation_tags_ids").val(),
                  "all_groups_ids": $("#all_groups_ids").val(),
                  "list": "true"
                },
                textColor: 'black',
                ignoreTimezone: false
            }
    };

  $('#calendar').fullCalendar({
    editable: false,
    header: {
            left: 'prev,next today',
            center: 'title',
            right: 'month,agendaWeek,agendaDay,list'
        },
        defaultView: 'month',
        height: 500,
        slotMinutes: 15,
        
        loading: function(bool){
          if (bool) 
              $('#loading').show();
          else 
              $('#loading').hide();
        },
        
        eventSources: [],
        edition: edition_param,
        ids_to_forms: ids_to_forms_param,
        timeFormat: 'h:mm t{ - h:mm t} ',
        dragOpacity: "0.5",
        contentHeight: 700,
        height: 1000,
        allDayText: "dia todo",
        // dayNamesShort: dayNames,

        eventRender: function(event, element) { 
        },

        eventClick: function(event, jsEvent, view){
          show_info_dropdown(event, jsEvent.currentTarget);
        },

        viewDisplay: function(view) {
          if(lastView!=null && lastView!=view.name){ // se mudou de visão
            if (view.name != 'list' && lastView == 'list') // se não for lista e a anterior for lista
              $('#calendar').fullCalendar('removeEventSource', fcSources.list)
                            .fullCalendar( 'addEventSource', fcSources.calendar);
            if(view.name == 'list') //se for lista
              $('#calendar').fullCalendar('removeEventSource', fcSources.calendar)
                            .fullCalendar( 'addEventSource', fcSources.list);
          }
          if(lastView == null) // primeira vez que abre calendário
            $('#calendar').fullCalendar( 'addEventSource', fcSources.calendar);  

          lastView = view.name;
         }
  });

});

function show_info_dropdown(event, div){
  var dropdown_panel = $(div).next('.dropdown');
  if(!dropdown_panel.length){
    var dropdown_content = $('<div class="dropdown-panel"></div>');
    var event_data = {
      "id": event.id,
      "type": event.type,
      "allocation_tags_ids": $("#allocation_tags_ids").val()
    };
    
    $.get("/schedule_events/dropdown_content", event_data, function(data){$(dropdown_content).append(data);});

    var dropdown = $("<div class='dropdown dropdown-tip' id='dropdown_details_"+event.type+"_"+event.id+"' style='z-index: 999;'></div>");
    $(dropdown).append(dropdown_content);
    $(div).after(dropdown);
  }
}
