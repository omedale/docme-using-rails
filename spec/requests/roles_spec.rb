require 'rails_helper'
require 'jwt'

RSpec.describe 'Roles API', type: :request do
  # initialize test data 
  let!(:roles) { create_list(:role, 4) }
  let!(:users) { create_list(:user, 4, role_id: roles.first.id) }
  let(:role_id) { roles.first.id }
  let!(:user_id) { users.first.id }

  # let(:auth_headers) {
  #   { 'HTTP-AUTHORIZATION' => 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE1MDYwOTE1NDR9.qYzck5J5ouRQPA7W-0S-RsI030YYIr_NHaoTR6sPpLQ' }
  # }

  describe 'GET /roles' do
    # before { get '/roles', {}, auth_headers }
    before do 
       token = JWT.encode({user_id: user_id}, Rails.application.secrets.secret_key_base)
       get '/roles', headers: {'Authorization': "#{token}" }
    end
 
    # before { get '/roles', headers: {
    #   'AUTHORIZATION': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE1MDYwOTE1NDR9.qYzck5J5ouRQPA7W-0S-RsI030YYIr_NHaoTR6sPpLQ' } }

    it 'returns roles' do
      expect(json).not_to be_empty
      expect(json.size).to eq(4)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /roles/:id' do

    before do 
      token = JWT.encode({user_id: user_id}, Rails.application.secrets.secret_key_base)
      get "/roles/#{role_id}", headers: {'Authorization': "#{token}" }
    end

    context 'when the record exists' do
      it 'returns the role' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(role_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:role_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Role/)
      end
    end
  end

  describe 'POST /roles' do
    # valid payload
    let(:valid_attributes) { { role: 'fellow', description: 'normal user' } }

    context 'when the request is valid' do
      before do 
        token = JWT.encode({user_id: user_id}, Rails.application.secrets.secret_key_base)
        post '/roles',  params: valid_attributes, headers: {'Authorization': "#{token}" }
      end

      it 'creates a role' do
        expect(json['role']).to eq('fellow')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before do 
        token = JWT.encode({user_id: user_id}, Rails.application.secrets.secret_key_base)
        post '/roles', params: { title: 'Pikolo' }, headers: {'Authorization': "#{token}" }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/Validation failed: Role can't be blank, Description can't be blank/)
      end
    end
  end

  describe 'PUT /roles/:id' do
    let(:valid_attributes) { { role: 'public' } }

    context 'when the record exists' do
      before do 
        token = JWT.encode({user_id: user_id}, Rails.application.secrets.secret_key_base)
        put "/roles/#{role_id}", params: valid_attributes, headers: {'Authorization': "#{token}" }
      end

      it 'updates the record' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end
  end

  describe 'DELETE /roles/:id' do
    before do 
      token = JWT.encode({user_id: user_id}, Rails.application.secrets.secret_key_base)
      delete "/roles/#{role_id}", headers: {'Authorization': "#{token}" }
    end

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end

end