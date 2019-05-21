class User < ActiveRecord::Base
  has_many :study_assignments

  def self.all_inactive
    Users.all.select do |user|
      StudyAssignment.where(user_uuid: user.uuid).any? { |assignment| !assignment.undeleted }
    end
  end

  def current_assignments
    study_assignments.undeleted
  end

  def assign_to_study(study_uuid, role, sites = [])
    assignment = study_assignments.find { |assignment| assignment.study_uuid == study_uuid }

    unless assignment.active
      assignment.active = true
    end

    if assignment
      if role.is_a?(Array)
        assignment.roles += role
        assignment.save
      else
        assignment.roles << role
        assignment.save
      end

      assignment.sites << sites
    else
      if role.is_a?(Array)
        StudyAssignment.new(study_uuid: study_uuid, roles: role, sites: sites)
      else
        StudyAssignment.new(study_uuid: study_uuid, roles: [role], sites: sites)
      end
    end

    courses = Course.find_by(study_uuid: study_uuid)
    course_completions = courses.map do |course|
      CourseCompletion.where(course_uuid: course.uuid, user_uuid: uuid)
    end

    course_completetions.all?
  end

  def remove_roles(study_uuid, roles)
    assignment = current_assignments.find { |assignment| assignment.study_uuid == study_uuid }
    assignment.roles.delete(roles)

    if assignment.roles.empty?
      assignment.active = false
    end

    assignment.save
  end

  def unassign_from_study(study_uuid)
    assignment = current_assignments.find { |assignment| assignment.study_uuid == study_uuid }
    assignment.roles = []
    assignment.active = false

    courses = Course.find_by(study_uuid: study_uuid)
    course_completions = courses.map do |course|
      CourseCompletion.where(course_uuid: course.uuid, user_uuid: uuid)
    end

    course_completions.each do |course_completion|
      course_completion.delete
    end
  end

  def unassign_from_all
    study_uuids = current_assignments.map { |assignment| assignment.study_uuid }
    current_assignments.each { |assignment| assignment.delete }

    courses = Course.find_by(study_uuid: study_uuids)
    course_completions = courses.map do |course|
      CourseCompletion.where(course_uuid: course.uuid, user_uuid: uuid)
    end

    course_completions.each do |course_completion|
      course_completion.delete
    end
  end

  def can_access?(resource)
    AuthorizationHelper.authorized?(user, resource)
  end
end
