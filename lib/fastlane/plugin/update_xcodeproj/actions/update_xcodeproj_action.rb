# frozen_string_literal: true

module Fastlane
  module Actions
    class UpdateXcodeprojAction < Action
      def self.run(params)
        require 'xcodeproj'

        options = params[:options]
        project_path = params[:xcodeproj]
        configurationName = params[:configuration]
        targetName = params[:target]
        project = Xcodeproj::Project.open(project_path)

        nativeTarget = project.native_targets.find { |obj| obj.name == targetName }
        UI.user_error!("Xcodeproj does not have target named '#{targetName}'") unless nativeTarget

        buildConfiguration =  nativeTarget.build_configurations.find { |obj| obj.name == configurationName }
        UI.user_error!("Xcodeproj does not have configuration named '#{configurationName}' in target '#{targetName}'") unless buildConfiguration

        options.each do |key, value|
          buildConfiguration.build_settings[key.to_s] = value
        end

        project.save

        UI.success("Updated #{params[:xcodeproj]} [target:#{targetName}] [configuration:#{configurationName}] 💾.")
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
                                       optional: false,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :target,
                                       env_name: "UPDATE_XCODEPROJ_TARGET",
                                       description: "Xcode project build target name",
                                       optional: false,
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
