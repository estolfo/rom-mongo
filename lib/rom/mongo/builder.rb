module ROM
  module Mongo
    module Builder

      SORT_DIRECTION_MAP = {
          asc: ::Mongo::Index::ASCENDING,
          desc: ::Mongo::Index::DESCENDING,
      }

      extend self

      def to_projection(fields)
        fields.inject({}) do |doc, f|
          doc.merge!(f => 1)
        end
      end


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
