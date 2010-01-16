# A simple example backend
require 'sinatra'
require 'json'

set :port, 9393
set :public, File.dirname(__FILE__) + '/..'

annotations = {}

def jsonpify(stuff)
  if params[:callback]
    "#{params[:callback]}(#{stuff.to_json})"
  else
    stuff.to_json
  end
end

before do
  if params['json']
    params['json'] = JSON.parse(params['json'])
  end
end

get %r{/store/annotations/?} do
  jsonpify(annotations.values)
end

put '/store/annotations' do
  if params['json']
    id = (annotations.keys.max || 0) + 1;
    annotations[id] = params['json']
    annotations[id]['id'] = id
    return 201, jsonpify(annotations[id])
  else
    return 400, 'No parameters given. Annotation not created'
  end
end

get '/store/annotations/:id' do |id|
  if annotations.has_key? id.to_i
    return jsonpify(annotations[id.to_i])
  else
    return 404, 'Annotation not found'
  end
end

post '/store/annotations/:id' do |id|
  if annotations.has_key? id.to_i
    if params['json']
      annotations[id.to_i].update(params['json'])
    end
    return 200, jsonpify(annotations[id.to_i])
  else
    return 404, 'Annotation not found'
  end
end

delete '/store/annotations/:id' do |id|
  if annotations.has_key? id.to_i
    annotations.delete(id.to_i)
    return 200
  else
    return 404, 'Annotation not found'
  end
end
