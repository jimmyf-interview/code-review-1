class StudyAssignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :study

  has_many :roles
  has_many :sites

  def self.undeleted
    where(deleted_at: nil)
  end

  def self.assign_user_to_study(user_uuid, study_uuid, roles, sites)
    assignment = where(user_uuid: user_uuid, study_uuid: study_uuid)

    if assignment
      assignment.update(roles: roles, sites: sites)
    else
      StudyAssignment.new(study_uuid: study.uuid, roles: roles, sites: sites)
    end
  end

  def self.unassign_user_from_study(user_uuid, study_uuid)
    assignment = where(user_uuid: user_uuid, study_uuid: study_uuid)
    assignment.update(roles: [], active: false)
  end

  def self.delete(user_uuid, study_uuid)
    assignment = where(user_uuid: user_uuid, study_uuid: study_uuid)
    assignment.delete
  end

  def is_active?
    ['enabled', 'open', 'accepted'].include?(status)
  end

  def set_status(new_status)
    status = new_status
    save!
  end
end
