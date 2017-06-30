require 'rom/mongo/relation'

RSpec.describe ROM::Mongo::Relation do
  include_context 'database'
  include_context 'users'

  describe '#by_pk' do
    it 'fetches a document by _id' do
      expect(users.by_pk(jane_id).one!.to_h).
        to eql(_id: jane_id, name: 'Jane', email: 'jane@doe.org')
    end
  end

  describe '#order' do
    it 'sorts documents' do
      expect(users.order(name: Mongo::Index::ASCENDING).only(:name).without(:_id).to_a.map(&:to_h)).
        to eql([{name: 'Jane',}, {name: 'Joe'}])

      expect(users.order(name: Mongo::Index::DESCENDING).only(:name).without(:_id).to_a.map(&:to_h)).
        to eql([{name: 'Joe'}, {name: 'Jane'}])
    end

    it 'supports mutli-field sorting' do
      expect(users.order(name: Mongo::Index::ASCENDING, email: Mongo::Index::ASCENDING).only(:name).without(:_id).to_a.map(&:to_h)).
        to eql([{name: 'Jane',}, {name: 'Joe'}])

      expect(users.order(email: Mongo::Index::ASCENDING, name: Mongo::Index::ASCENDING).only(:name).without(:_id).to_a.map(&:to_h)).
        to eql([{name: 'Joe',}, {name: 'Jane'}])
    end
  end
end
