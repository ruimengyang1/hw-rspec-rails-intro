require 'rails_helper'

describe MoviesController, type: :controller do
  describe 'searching TMDb' do
    before :each do
      @fake_results = [double('movie1'), double('movie2')]
    end

    it 'calls the model method that performs TMDb search' do
      expect(Movie).to receive(:find_in_tmdb).with(
        hash_including(title: 'hardware')
      ).and_return(@fake_results)

      get :search_tmdb, params: { title: 'hardware', language: 'en' }
    end

    describe 'after valid search' do
      before :each do
        allow(Movie).to receive(:find_in_tmdb).and_return(@fake_results)
        get :search_tmdb, params: { title: 'hardware', language: 'en' }
      end

      it 'selects the Search Results template for rendering' do
        expect(response).to render_template('search_tmdb')
      end

      it 'makes the TMDb search results available to that template' do
        expect(assigns(:movies)).to eq(@fake_results)
      end
    end

    it 'shows an error if title is missing' do
      get :search_tmdb, params: { release_year: '2000', language: 'en' }

      expect(flash[:danger]).to eq('Please fill in all required fields!')
      expect(assigns(:movies)).to eq([])
    end
  end

  describe 'adding a movie from TMDb results' do
    it 'creates a new movie and redirects to the search page' do
      expect {
        post :add_movie, params: {
          title: 'Limitless',
          rating: 'R',
          description: 'A writer discovers a powerful drug.',
          release_date: '2011-03-08'
        }
      }.to change(Movie, :count).by(1)

      expect(response).to redirect_to(search_tmdb_path)
      expect(flash[:success]).to eq('Limitless was successfully added to RottenPotatoes.')
    end
  end
end