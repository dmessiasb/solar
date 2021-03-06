module CurriculumUnitsHelper

  def message_class_participants (user_id, curriculum_unit, profile_flag, have_profile = true, offer_id = nil, group_id = nil)
    if curriculum_unit
      allocation_tag_id = AllocationTag.find_by_curriculum_unit_id(curriculum_unit).id

      # allocation_tag_id será a de unidade curricular se houver allocation para o usuário
      if Allocation.find_by_user_id_and_allocation_tag_id(user_id, allocation_tag_id).nil?
        if offer_id
          allocation_tag_id = AllocationTag.find_by_group_id(offer_id).id

          # allocation_tag_id será a de oferta se houver allocation para o usuário
          if Allocation.find_by_user_id_and_allocation_tag_id(user_id, allocation_tag_id).nil?
            if group_id
              allocation_tag_id = AllocationTag.find_by_group_id(group_id).id
            end
          end
        elsif group_id # Caso oferta seja nil
          allocation_tag_id = AllocationTag.find_by_group_id(group_id).id
        end
      end

      negative = have_profile ? '' : 'NOT'
      query = "
            SELECT DISTINCT
              users.id, users.name as username, users.photo_file_name, users.email, p.name as profilename, p.id as profileid
            FROM
              allocations al
              inner join profiles p on al.profile_id = p.id
              INNER JOIN users  ON al.user_id = users.id
              inner join
              (select
                     root.id as allocation_tag_id,
                     CASE
                       WHEN group_id is not null THEN (select 'GROUP'::text)
                       WHEN offer_id is not null THEN (select 'OFFER'::text)
                       WHEN course_id is not null THEN (select 'COURSE'::text)
                       ELSE (select 'CURRICULUM_UNIT'::text)
                     END as entity_type,
                     (coalesce(group_id, 0) + coalesce(offer_id, 0) +
              coalesce(curriculum_unit_id, 0) + coalesce(course_id, 0)) as entity_id,
                    --parents do tipo offer
                     CASE
                       WHEN group_id is not null THEN (
                         select coalesce(t.id,0)
                         from
                           groups g
                           left join allocation_tags t on t.offer_id = g.offer_id
                         where
                           g.id = root.group_id
                       )
                       ELSE (select 0)
                     END as offer_parent_tag_id,

                     --parents do tipo curriculum unit
                     CASE
                       WHEN group_id is not null THEN (
                         select coalesce(t.id,0)
                         from
                           groups g
                           left join offers o on g.offer_id = o.id
                           left join allocation_tags t on t.curriculum_unit_id = o.curriculum_unit_id
                         where
                           g.id = root.group_id
                       )
                       WHEN offer_id is not null THEN (
                         select coalesce(t.id,0)
                         from
                           offers o
                           left join allocation_tags t on t.curriculum_unit_id = o.curriculum_unit_id
                         where
                           o.id = root.offer_id
                       )
                       ELSE (select 0)
                     END as curriculum_unit_parent_tag_id,

                     --parents do tipo course
                     CASE
                       WHEN group_id is not null THEN (
                         select coalesce(t.id,0)
                         from
                           groups g
                           left join offers o on g.offer_id = o.id
                           left join allocation_tags t on t.course_id = o.course_id
                         where
                           g.id = root.group_id
                       )
                       WHEN offer_id is not null THEN (
                         select coalesce(t.id,0)
                         from
                           offers o
                           left join allocation_tags t on t.course_id = o.course_id
                         where
                           o.id = root.offer_id
                       )
                       ELSE (select 0)
                     END as course_parent_tag_id
              from
                     allocation_tags root
              order by entity_type, allocation_tag_id) as hierarchy
              on
                (al.allocation_tag_id = hierarchy.allocation_tag_id) or
                (al.allocation_tag_id = hierarchy.offer_parent_tag_id) or
                (al.allocation_tag_id = hierarchy.curriculum_unit_parent_tag_id) or
                (al.allocation_tag_id = hierarchy.course_parent_tag_id)
            where
                #{negative} cast( p.types & '#{profile_flag.to_s(2)}' as boolean) AND
                al.status=#{Allocation_Activated} AND
                (
                  (hierarchy.allocation_tag_id = #{allocation_tag_id}) or
                  (hierarchy.offer_parent_tag_id = #{allocation_tag_id}) or
                  (hierarchy.curriculum_unit_parent_tag_id = #{allocation_tag_id}) or
                  (hierarchy.course_parent_tag_id = #{allocation_tag_id})
                )
           ORDER BY profilename, users.name"

      participants = User.find_by_sql(query)

      return participants
    else
      return nil
    end
  end
end
