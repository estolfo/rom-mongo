require 'rom/mongo/builder'

module ROM
  module Mongo

    # This is a class interfacing with the MongoDB Ruby driver.
    # It provides a DSL for constructing queries and writes.
    class Dataset

      # The collection object.
      #
      # @return [ Mongo::Collection ] The collection object.
      attr_reader :collection

      # The collection view object.
      #
      # @return [ Mongo::Collection::View ] The collection view object.
      attr_reader :criteria

      # Initialize the Dataset object.
      #
      # @example Create a Dataset object.
      #   Dataset.new(collection, { name: 'Emily' })
      #
      # @param [ Mongo::Collection ] collection The collection to run the operation on.
      # @param [ Mongo::Collection::View ] criteria The collection view object.
      #
      def initialize(collection, criteria = nil)
        @collection = collection
        @criteria = criteria || collection.find
      end

      # Construct a Dataset object with query criteria.
      #
      # @example Create a Dataset object
      #   dataset.find({ name: 'Emily' })
      #
      # @param [ Hash ] criteria The query selector.
      #
      # @return [ Dataset ] The new database object with the specified query selector.
      def find(criteria = {})
        Dataset.new(collection, collection.find(criteria))
      end

      # Perform the query and return the results.
      #
      # @example Perform the query.
      #   dataset.to_a
      #
      # @return [ Array<Hash> ] An array of the result set.
      def to_a
        view.to_a
      end

      # Insert a single document into the collection.
      #
      # @example Insert a document
      #   dataset.insert( { name: 'Emily' })
      #
      # @param [ Hash ] data The document to insert.
      #
      # @return [ Mongo::Result ] The result of the insert operation.
      def insert(data)
        collection.insert_one(data)
      end

      # Update multiple documents in the collection.
      #
      # @example Update many documents in the collection.
      #   dataset.update_all({ :name => "Emily" }, { "$set" => { :name => "Em" } })
      #
      # @param [ Hash ] update The update document.
      #
      # @return [ Mongo::Result ] The result of the update operation.
      def update_all(update)
        view.update_many(update)
      end

      # Remove all documents in the collection.
      #
      # @example Remove all documents.
      #   dataset.remove_all
      #
      # @return [ Mongo::Result ] The result of the delete operation.
      def remove_all
        view.delete_many
      end

      # Construct a Collection View with a given selector.
      #
      # @example Construct a View with query criteria.
      #   dataset.where({ name: 'Emily' })
      #
      # @param [ Hash ] doc The query criteria.
      #
      # @return [ Dataset ] A dataset object with the given query criteria.
      def where(doc)
        dataset(criteria.find(doc))
      end

      # Specify that only certain fields should be returned from the query.
      #
      # @example Define the fields to return from the query.
      #   dataset.only(:name)
      #
      # @param [ Hash ] fields The fields to project.
      #
      # @return [ Dataset ] The dataset object with the project set.
      def only(fields)
        dataset(criteria.projection(Builder.to_projection_doc(fields)))
      end

      # Define fields to exclude from the result documents.
      #
      # @example Define the fields to exclude from the result documents.
      #   dataset.without([:name, :address])
      #
      # @param [ Array<Symbol> ] fields The fields to exclude.
      #
      # @return [ Dataset ] The dataset object with certain fields specified to be excluded.
      def without(fields)
        dataset(criteria.without(fields))
      end

      # Define a limit on the query.
      #
      # @example Define a limit.
      #   dataset.limit(10)
      #
      # @param [ Integer ] limit The limit value.
      #
      # @return [ Dataset ] The dataset object with limit set.
      def limit(limit)
        dataset(criteria.limit(limit))
      end

      # Define a skip on the query.
      #
      # @example Define a limit.
      #   dataset.skip(5)
      #
      # @param [ Integer ] value The skip value.
      #
      # @return [ Dataset ] The dataset object with skip set.
      def skip(value)
        dataset(criteria.skip(value))
      end

      # Define a sort on the query.
      #
      # @example Define a srt.
      #   dataset.sort(name: 1)
      #
      # @param [ Hash ] value The sort document.
      #
      # @return [ Dataset ] The dataset object with the sort set.
      def sort(value)
        dataset(criteria.sort(Builder.to_sort_doc(value)))
      end
      alias :order :sort

      # @api private
      def each
        view.each { |doc| yield(doc) }
      end

      # @api private
      def map(&block)
        to_a.map(&block)
      end

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
