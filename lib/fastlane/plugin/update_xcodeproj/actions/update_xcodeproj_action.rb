# frozen_string_literal: true

module Fastlane
  module Actions
    class UpdateXcodeprojAction < Action
      def self.run(params)
        require 'xcodeproj'

        options = params[:options]
        project_path = params[:xcodeproj]
        configuration = params[:configuration]
        project = Xcodeproj::Project.open(project_path)

        options.each do |key, value|
          configs = project.objects.select { |obj| obj.isa == 'XCBuildConfiguration' && obj.name == configuration }
          UI.user_error!("Xcodeproj does not have configuration named #{configuration}") if configs.count.zero?

          configs.each do |c|
            c.build_settings[key.to_s] = value
          end
        end

        project.save

        UI.success("Updated #{params[:xcodeproj]} 💾.")
      end

      def self.description
        "Update Xcode projects"
      end

      def self.authors
        ["Fumiya Nakamura"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                       env_name: "UPDATE_XCODEPROJ_XCODEPROJ",
                                       description: "Path to your Xcode project",
                                       optional: true,
                                       default_value: Dir['*.xcodeproj'].first,
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass the path to the project, not the workspace") unless value.end_with?(".xcodeproj")
                                         UI.user_error!("Could not find Xcode project") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :configuration,
                                       env_name: "UPDATE_XCODEPROJ_CONFIGURATION",
                                       description: "Xcode project build configuration name",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :options,
                                       env_name: "UPDATE_XCODEPROJ_OPTIONS",
                                       description: "Key & Value pair that you will update xcode project",
                                       optional: false,
                                       type: Hash)
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
