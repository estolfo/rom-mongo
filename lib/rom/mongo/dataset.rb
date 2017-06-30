module ROM
  module Mongo
    class Dataset

      def initialize(collection, criteria = nil)
        @collection = collection
        @criteria = criteria || collection.find
      end

      attr_reader :collection

      attr_reader :criteria

      def find(criteria = {})
        Dataset.new(collection, collection.find(criteria))
      end

      def to_a
        view.to_a
      end

      # @api private
      def each
        view.each { |doc| yield(doc) }
      end

      # @api private
      def map(&block)
        to_a.map(&block)
      end

      def insert(data)
        collection.insert_one(data)
      end

      def update_all(attributes)
        view.update_many(attributes)
      end

      def remove_all
        view.delete_many
      end

      def where(doc)
        dataset(criteria.where(doc))
      end

      def only(fields)
        projection_doc = fields.inject({}) do |doc, f|
          doc.merge!(f => 1)
        end
        dataset(criteria.projection(projection_doc))
      end

      def without(fields)
        dataset(criteria.without(fields))
      end

      def limit(limit)
        dataset(criteria.limit(limit))
      end

      def skip(value)
        dataset(criteria.skip(value))
      end

      def sort(value)
        dataset(criteria.sort(value))
      end
      alias :order :sort

      private

      def view
        with_options(collection.find(criteria.selector), criteria.options)
      end

      def dataset(criteria)
        Dataset.new(collection, criteria)
      end

      # Applies given options to the view
      #
      # @api private
      def with_options(view, options)
        map = { fields: :projection }
        options.each do |option, value|
          option = map.fetch(option, option)
          view = view.send(option, value) if view.respond_to?(option)
        end
        view
      end
    end
  end
end
