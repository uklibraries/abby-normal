module Api
  module V1
    class TasksController < ApplicationController
      before_filter :restrict_access

      respond_to :json

      def claim
        task = Task.where(
          :type_id => Type.where(:name => params[:type]).first,
          :status_id => Status.ready.id
        ).first

        if task
          task.status = Status.started
          task.save
          render :json => {:package => Package.find(task.package_id),
                           :task => task }
        else
          render :json => {}
        end
      end

      def update
        task_id = params[:id].to_i
        task = Task.find(task_id)
        status = Status.where(:name => params[:name]).first
        if task and status
          task.status = status
          task.save
          render :json => Task.find(task_id)
        else
          render :json => {}
        end
      end

    private
    
      def restrict_access
        authenticate_or_request_with_http_token do |token, options|
          ApiKey.exists?(access_token: token)
        end
      end
    end
  end
end
