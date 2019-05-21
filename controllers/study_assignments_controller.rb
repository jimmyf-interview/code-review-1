class StudyAssignmentsController < ApplicationController
  def index
    study = fetch_study

    if AuthorizationHelper.authorized?(user, study)
      study_assignments = StudyAssignment.where(study_uuid: study.uuid)
      active_study_assignments = study_assignments.select { |study_assignment| study_assignment.is_active? }
      render json: active_study_assignments
    else
      render status: :unauthorized
    end
  end

  def show
    study = fetch_study

    if AuthorizationHelper.authorized?(user, study)
      study_assignment = StudyAssignment.find_by(study_uuid: study.uuid, user_uuid: params[:user_uuid])
      render json: study_assignment
    else
      render status: :unauthorized
    end
  end

  def fetch_study
    Study.find_by(uuid: params[:study])
  end
end
