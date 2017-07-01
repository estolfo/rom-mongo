require 'spec_helper'

RSpec.describe ROM::Mongo::Builder do

  describe '#to_projection' do

    let(:result) do
      described_class.to_projection([:name, :address])
    end

    it 'converts the fields into a document with 1 values' do
      expect(result).to eq({ name: 1, address: 1})
    end
  end

  describe '#to_sort_doc' do

    let(:result) do
      described_class.to_sort_doc(arg)
    end

    context 'when symbols are used as the direction' do

      let(:arg) do
        {name: :asc, address: :desc}
      end

      it 'converts the fields into a document with 1 values' do
        expect(result).to eq({ name: 1, address: -1 })
      end
    end

    context 'when integers are used as the direction' do

      let(:arg) do
        {name: 1, address: -1}
      end

      it 'converts the fields into a document with 1 values' do
        expect(result).to eq({ name: 1, address: -1 })
      end
    end

    context 'when the direction is invalid' do

      let(:arg) do
        {name: 1, address: :invalid}
      end

      it 'ignores the invalid direction' do
        expect(result).to eq({ name: 1 })
      end
    end
  end
end