require 'moped'
require 'uri'

require 'rom/repository'

require 'rom/mongo/dataset'
require 'rom/mongo/commands'

module ROM
  module Mongo
    class Relation < ROM::Relation
      forward :insert, :find
    end

    class Repository < ROM::Repository
      attr_reader :collections

      def initialize(uri)
        host, database = uri.split('/')
        @connection = Moped::Session.new([host])
        @connection.use database
        @collections = {}
      end

      def [](name)
        collections.fetch(name)
      end

      def dataset(name)
        collections[name] = Dataset.new(connection[name])
      end

      def dataset?(name)
        connection.collection_names.include?(name.to_s)
      end

      def command_namespace
        Mongo::Commands
      end
    end
  end
end
