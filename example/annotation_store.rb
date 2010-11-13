# A simple example backend
require 'sinatra'
require 'json'

Sinatra::Delegator.delegate :route

set :port, 9393
set :public, File.dirname(__FILE__) + '/..'

annotations = {}

def jsonpify(stuff)
  if params[:callback]
    content_type 'text/javascript', :charset => 'utf-8'
    "#{params[:callback]}(#{stuff.to_json})"
  else
    stuff.to_json
  end
end

before do
  content_type 'application/json', :charset => 'utf-8'

  if params['json']
    params['json'] = JSON.parse(params['json'])
  end

  response['Access-Control-Allow-Origin']   = '*'
  response['Access-Control-Expose-Headers'] = 'Location'
  response['Access-Control-Allow-Methods']  = 'GET, POST, PUT, DELETE'
  response['Access-Control-Max-Age']        = '86400'
end

route 'OPTIONS', /.+/ do
  204
end

get %r{^/store/annotations/?$} do
  [200, jsonpify(annotations.values)]
end

post '/store/annotations' do
  if params['json']
    id = (annotations.keys.max || 0) + 1;
    annotations[id] = params['json']
    annotations[id]['id'] = id
    redirect "/store/annotations/#{id}", 303
  else
    [400, 'No parameters given. Annotation not created']
  end
end

get '/store/annotations/:id' do |id|
  if annotations.has_key? id.to_i
    [200, jsonpify(annotations[id.to_i])]
  else
    [404, 'Annotation not found']
  end
end

put '/store/annotations/:id' do |id|
  if annotations.has_key? id.to_i
    if params['json']
      annotations[id.to_i].update(params['json'])
    end
    [200, jsonpify(annotations[id.to_i])]
  else
    [404, 'Annotation not found']
  end
end

delete '/store/annotations/:id' do |id|
  if annotations.has_key? id.to_i
    annotations.delete(id.to_i)
    204
  else
    [404, 'Annotation not found']
  end
end

get '/store/search' do
  results = annotations.values.select do |ann|
    params.all? { |key, val| ann[key].to_s == val }
  end
  jsonpify({:total => results.length, :results => results})
end
