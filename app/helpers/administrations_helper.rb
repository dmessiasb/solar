module AdministrationsHelper

	include AllocationsHelper

	def last_accessed(id)
		last_accessed = Log.find_by_user_id(id)
		if !last_accessed.nil?
			l(last_accessed.created_at.to_date, :format => :default).to_s 
    else
    	" - "
    end
	end

	def allocation_details(allocation_tag)
		AllocationTag.allocation_tag_details(allocation_tag)
	end

	def type(allocation_tag)
		AllocationTag.curriculum_unit_type(allocation_tag)
	end

	def name_allocation_status(status)
		name_of(status)
	end

	def allocation_status
		status = status_hash
	end

	def name_user_status(status)
		status ? user_status[1] : user_status[0]
	end

	def user_status
    { 0 => t(:blocked), 1 => t(:active) }
  end
end