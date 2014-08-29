module Api
  module V1
    class BatchesController < ApplicationController
      before_filter :restrict_access
      respond_to :json

      def index
        respond_with Batch.all
      end

      def show
        respond_with Batch.find(params[:id])
      end

      def create
        batch = JSON.parse(params[:batch])
        respond_with Batch.create(batch)
      end

      def update
        respond_with Batch.update(params[:id], JSON.parse(params[:batch]))
      end

      def destroy
        respond_with Batch.destroy(params[:id])
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
