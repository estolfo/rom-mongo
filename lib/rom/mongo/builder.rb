module ROM
  module Mongo

    # An auxillary module for converting arguments to objects for the MongoDB
    #   Ruby driver's API.
    #
    # @since 0.3.0
    module Builder

      extend self

      # A map from symbol sort directions to their corresponding values in MongoDB's API.
      #
      # @since 0.3.0
      SORT_DIRECTION_MAP = {
          asc: ::Mongo::Index::ASCENDING,
          desc: ::Mongo::Index::DESCENDING,
      }.freeze

      # Convert a list of fields into a projection document.
      #
      # @example Create a projection document from a list of fields.
      #   Builder.to_projection_doc([:name])
      #
      # @param [ Array<String, Symbol> ] fields The list of fields.
      #
      # @return [ Hash ] The projection document.
      #
      # @since 0.3.0
      def to_projection_doc(fields)
        fields.inject({}) do |doc, f|
          doc.merge!(f => 1)
        end
      end

      # Convert a sort document to comply with MongoDB's API.
      #
      # @example Convert a sort document.
      #   Builder.to_sort_doc({ name: :asc })
      #
      # @ [ Hash ] doc The sort document.
      #
      # @return [ Hash ] The converted sort document.
      #
      # @since 0.3.0
      def to_sort_doc(doc)
        doc.inject({}) do |sort_doc, (key, value)|
          if SORT_DIRECTION_MAP.values.include?(value)
            sort_doc.merge!(key => value)
          elsif direction = SORT_DIRECTION_MAP[value]
            sort_doc.merge!(key => direction)
          else
            sort_doc
          end
        end
      end
    end
  end
end
