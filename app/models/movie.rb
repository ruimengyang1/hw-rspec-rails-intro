require 'set'

class Movie < ApplicationRecord
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end

  def self.find_in_tmdb(query, api_key = ENV['TMDB_API_KEY'])
    return Faraday.get(query) if query.is_a?(String) && query.start_with?('http')

    search_params =
      if query.is_a?(String)
        { title: query }
      else
        query.symbolize_keys
      end

    response = Faraday.get('https://api.themoviedb.org/3/search/movie') do |req|
      req.params['api_key'] = api_key if api_key.present?
      req.params['query'] = search_params[:title]
      req.params['primary_release_year'] = search_params[:release_year] if search_params[:release_year].present?
      req.params['language'] = 'en-US' if search_params[:language] == 'en'
    end

    parsed = JSON.parse(response.body)
    results = parsed['results'] || []

    existing_titles = Movie.pluck(:title).map(&:downcase).to_set

    results.filter_map do |movie_data|
      next if existing_titles.include?(movie_data['title'].to_s.downcase)

      release_date =
        begin
          movie_data['release_date'].present? ? Date.parse(movie_data['release_date']) : nil
        rescue ArgumentError
          nil
        end

      Movie.new(
        title: movie_data['title'],
        rating: 'R',
        description: movie_data['overview'],
        release_date: release_date
      )
    end
  end
end