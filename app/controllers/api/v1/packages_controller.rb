module Api
  module V1
    class PackagesController < ApplicationController
      before_filter :restrict_access

      respond_to :json

      def index
        respond_with Package.all
      end

      def show
        respond_with Package.find(params[:id])
      end

      def create
        package = JSON.parse(params[:package])
        package[:project_info_id] ||= "1"
        respond_with Package.create(package)
      end

      def update
        respond_with Package.update(params[:id], JSON.parse(params[:package]))
      end

      def destroy
        respond_with Package.destroy(params[:id])
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
