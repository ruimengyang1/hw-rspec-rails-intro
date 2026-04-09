require 'rails_helper'
require 'spec_helper'

describe Movie do
  describe '.find_in_tmdb' do
    it 'calls Faraday' do
      fake_response = double('response', body: JSON.generate({ results: [] }))
      expect(Faraday).to receive(:get).and_return(fake_response)
      Movie.find_in_tmdb({ title: 'hacker', language: 'en' })
    end

    it 'returns a list of Movie objects from TMDb results' do
      results = Movie.find_in_tmdb({ title: 'olympics', release_year: '2000', language: 'en' })

      expect(results).to be_an(Array)
      expect(results).not_to be_empty
      expect(results.first).to be_a(Movie)
      expect(results.first.title).to eq('Sydney 2000 Olympics Opening Ceremony')
      expect(results.first.rating).to eq('R')
    end

    it 'does not return movies already saved in the database' do
      Movie.create!(
        title: 'Sydney 2000 Olympics Opening Ceremony',
        rating: 'R',
        description: 'Already saved',
        release_date: Date.parse('2000-09-15')
      )

      results = Movie.find_in_tmdb({ title: 'olympics', release_year: '2000', language: 'en' })

      titles = results.map(&:title)
      expect(titles).not_to include('Sydney 2000 Olympics Opening Ceremony')
    end
  end
end