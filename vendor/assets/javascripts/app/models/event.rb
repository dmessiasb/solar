module Event

  def self.included(base)
    # recupera os eventos que pertençam ao período visualizado e que tenham relação com as allocations_tags passadas
    base.scope :between, lambda {|start_time, end_time, allocation_tags| {joins: [:schedule, academic_allocations: :allocation_tag], conditions: ["
      ((schedules.end_date < ?) OR (schedules.start_date < ?)) AND ((schedules.start_date > ?) OR (schedules.end_date > ?))
      AND allocation_tags.id IN (?)", 
      format_date(end_time), format_date(end_time), format_date(start_time), format_date(start_time), allocation_tags] }}
  end

  def schedule_json(options = {})
    {
      id: id,
      title: respond_to?(:name) ? name : title, # o fullcalendar espera receber title
      description: (respond_to?(:enunciation) ? enunciation : description) || "",
      start: schedule.start_date,
      :end => schedule.end_date,
      allDay: (not respond_to?(:start_hour) or start_hour.blank?), # se não tiver hora de inicio e fim é do dia todo
      recurring: (respond_to?(:start_hour) and respond_to?(:end_hour) and not(start_hour.blank? or end_hour.blank?)), # se tiver hora de inicio e fim, é recorrente de todo dia no intervalo
      # repeats: (schedule.end_date.to_date - schedule.start_date.to_date),
      # repeat_freq: 1,
      # url: Rails.application.routes.url_helpers.discussion_path(id, allocation_tags_ids: 'at_param'),
      start_hour: (respond_to?(:start_hour) ? start_hour : nil),
      end_hour: (respond_to?(:end_hour) ? end_hour : nil),
      color: verify_type(self.class.to_s, (respond_to?(:type_event) ? type_event : nil)),
      type: self.class.name.tableize.singularize
    }
  end

  def self.format_date(date_time)
    Time.at(date_time.to_i).to_formatted_s(:db)
  end

  def verify_type(model_name, type_event)
    return (
      case model_name
        when "Assignment"
          "#CCCCFF"
        when "ChatRoom"
          "#A7C1F0"
        when "Discussion"
          "#CAFCCC"
        when "ScheduleEvent"
          if type_event == 1
            "#F5D5EF"
          elsif type_event == 2
            "#FFD9E0"
          else
            "#E3E3E3"
          end
        else
          "#FCEBCA"
      end
    )
  end

end
