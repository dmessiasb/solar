class Score < ActiveRecord::Base

  self.table_name = "assignment_comments"

  ##
  # Recupera a quantidade de acessos de um usuario em uma unidade curricular
  ##
  def self.find_amount_access_by_student_id_and_interval(curriculum_unit_id, student_id, from_date, until_date)
    conditions = "user_id = #{student_id}
        AND curriculum_unit_id = #{curriculum_unit_id}
        AND log_type = #{Log::TYPE[:course_access]}
        AND created_at::date BETWEEN '#{from_date}' AND '#{until_date}'"
    
    Log.where(conditions).count
  end

  ##
  # Recupera historico de acessos
  ##
  def self.history_student_id_and_interval(curriculum_unit_id, student_id, from_date, until_date)
    query = <<SQL
   SELECT t2.name               AS curriculum_unit_name,
          t1.created_at         AS access_date
     FROM logs                  AS t1
     JOIN curriculum_units      AS t2 ON t2.id = t1.curriculum_unit_id
     WHERE t2.id = #{curriculum_unit_id}
       AND t1.log_type = #{Log::TYPE[:course_access]}
       AND t1.user_id = #{student_id}
       AND t1.created_at::date BETWEEN '#{from_date}' AND '#{until_date}'
     ORDER BY t1.created_at DESC;
SQL

    history = ActiveRecord::Base.connection.select_all query

    return (history.nil?) ? [] : history
  end

  ## 
  # Recupera informações de todos os alunos para todas as atividades de uma turma
  ##
  def self.students_information(students, assignments, curriculum_unit_id, allocation_tag_id)
    students_grades, students_groups, student_count_access, student_count_public_files = [], [], [], [] # informações do aluno

    students.each_with_index do |student, idx|

      assignments_grades, groups_ids = [], [] # informações do aluno na atividade

      assignments.each do |assignment|
        student_group = assignment.student_group_by_student(student.id)
        student_id = (assignment.type_assignment == Assignment_Type_Group) ? nil : student.id # se for atividade de groupo, id do aluno é nulo
        groups_ids << (student_group.nil? ? nil : student_group.id) # se aluno estiver em grupo, recupera id
        sent_assignment = assignment.sent_assignment_by_user_id_or_group_assignment_id(allocation_tag_id, student_id, groups_ids)
        grade = ((sent_assignment.nil? or sent_assignment.assignment_files.empty?) ? "an" : "as") # nota ou situação do aluno (an: trabalho não enviado, as: trabalho não corrigido)
        if (assignment.type_assignment == Assignment_Type_Group and student_group.nil?)
          assignments_grades << "without_group"
        else 
          assignments_grades << ((sent_assignment and not sent_assignment.grade.nil?) ? sent_assignment.grade : grade)
        end
      end  

      students_grades[idx] = assignments_grades
      students_groups[idx] = groups_ids
      student_count_access[idx] = Log.find_all_by_user_id_and_log_type_and_curriculum_unit_id(student.id, 3, curriculum_unit_id).size
      student_count_public_files[idx] = PublicFile.find_all_by_user_id_and_allocation_tag_id(student.id, allocation_tag_id).size
    end

    return {"students_grades" => students_grades, "students_groups" => students_groups, "student_count_access" => student_count_access, "student_count_public_files" => student_count_public_files}
  end
  
  # Numero de estudantes por turma
  def self.number_of_students_by_group_id(group_id)
    query = <<SQL
  SELECT COUNT(DISTINCT t1.id)::int AS cnt
     FROM users             AS t1
     JOIN allocations       AS t2 ON t2.user_id = t1.id
     JOIN allocation_tags   AS t3 ON t3.id = t2.allocation_tag_id
     JOIN profiles          AS t4 ON t4.id = t2.profile_id
    WHERE t3.group_id = #{group_id}
      AND cast(t4.types & '#{Profile_Type_Student}' as boolean)
      AND t2.status = #{Allocation_Activated};
SQL

    cnt = ActiveRecord::Base.connection.select_all query

    return (cnt.nil?) ? 0 : cnt.first["cnt"].to_i
  end


end
