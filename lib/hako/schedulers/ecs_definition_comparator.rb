# frozen_string_literal: true
require 'hako/schema'

module Hako
  module Schedulers
    class EcsDefinitionComparator
      # @param [Hash] expected_container
      def initialize(expected_container)
        @expected_container = expected_container
        @schema = definition_schema
      end

      # @param [Aws::ECS::Types::ContainerDefinition] actual_container
      # @return [Boolean]
      def different?(actual_container)
        !@schema.same?(actual_container.to_h, @expected_container)
      end

      private

      def definition_schema
        Schema::Structure.new.tap do |struct|
          struct.member(:image, Schema::String.new)
          struct.member(:cpu, Schema::Integer.new)
          struct.member(:essential, Schema::Boolean.new)
          struct.member(:memory, Schema::Integer.new)
          struct.member(:memory_reservation, Schema::Nullable.new(Schema::Integer.new))
          struct.member(:links, Schema::UnorderedArray.new(Schema::String.new))
          struct.member(:port_mappings, Schema::UnorderedArray.new(port_mapping_schema))
          struct.member(:environment, Schema::UnorderedArray.new(environment_schema))
          struct.member(:docker_labels, Schema::Table.new(Schema::String.new, Schema::String.new))
          struct.member(:mount_points, Schema::UnorderedArray.new(mount_point_schema))
          struct.member(:command, Schema::Nullable.new(Schema::OrderedArray.new(Schema::String.new)))
          struct.member(:volumes_from, Schema::UnorderedArray.new(volumes_from_schema))
          struct.member(:user, Schema::Nullable.new(Schema::String.new))
          struct.member(:privileged, Schema::Boolean.new)
          struct.member(:log_configuration, Schema::Nullable.new(log_configuration_schema))
        end
      end

      def port_mapping_schema
        Schema::Structure.new.tap do |struct|
          struct.member(:container_port, Schema::Integer.new)
          struct.member(:host_port, Schema::Integer.new)
          struct.member(:protocol, Schema::String.new)
        end
      end

      def environment_schema
        Schema::Structure.new.tap do |struct|
          struct.member(:name, Schema::String.new)
          struct.member(:value, Schema::String.new)
        end
      end

      def mount_point_schema
        Schema::Structure.new.tap do |struct|
          struct.member(:source_volume, Schema::String.new)
          struct.member(:container_path, Schema::String.new)
          struct.member(:read_only, Schema::Boolean.new)
        end
      end

      def volumes_from_schema
        Schema::Structure.new.tap do |struct|
          struct.member(:source_container, Schema::String.new)
          struct.member(:read_only, Schema::Boolean.new)
        end
      end

      def log_configuration_schema
        Schema::Structure.new.tap do |struct|
          struct.member(:log_driver, Schema::String.new)
          struct.member(:options, Schema::Table.new(Schema::String.new, Schema::String.new))
        end
      end
    end
  end
end
