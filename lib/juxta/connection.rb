require 'json'
require 'rest_client'
require 'base64'

class Connection

   attr_reader :url
   attr_accessor :workspace

   def initialize( url, username=nil, password=nil )

      @authtoken = "Basic #{Base64.encode64("#{username}:#{password}")}"
      @url = "#{url}/juxta"
      @workspace = "public"
      
      @timeout = 600        # 10 minute get timeout...
      @open_timeout = 600   # 10 minute post timeout

      opts = {
          :timeout => @timeout,
          :open_timeout=> @open_timeout
      }

      @rest_client = RestClient::Resource.new( @url, opts )
   end

   def get_ws_version()
      start_time = Time.now.to_f
      resp = @rest_client.get :content_type => "application/json", :authorization => @authtoken
      dump_time( "get", start_time )
      json = JSON.parse(resp)
      return json['version']
   end

   def get( request, in_workspace=true )
      start_time = Time.now.to_f
      url = in_workspace ? make_url( request ) : request 
      resp = @rest_client[ url ].get :content_type => "application/json", :accept=>'application/json', :authorization => @authtoken
      dump_time( "get", start_time )
      JSON.parse(resp)
   end
   
   def get_html( request )
      start_time = Time.now.to_f
      resp = @rest_client[ make_url( request ) ].get :content_type => "text/html", :authorization => @authtoken
      dump_time( "get", start_time )
      return resp
   end
   
   def get_xml( request )
      start_time = Time.now.to_f
      resp = @rest_client[ make_url( request ) ].get :content_type => "text/xml", :authorization => @authtoken
      dump_time( "get", start_time )
      return resp
   end

   def post( request, payload, in_workspace=true )
      start_time = Time.now.to_f
      url = in_workspace ? make_url( request ) : request   
      if payload.nil? == true
         resp = @rest_client[ url ].post "", :authorization => @authtoken
      else
         resp = @rest_client[ url ].post payload.to_json, :authorization => @authtoken, :content_type => "application/json"
      end
      dump_time( "post", start_time )
      return resp
   end
      
   def upload_file( file_name, content_type, file ) 
      opts = {
         :sourceName=> file_name,
         :contentType => content_type, 
         :sourceFile=> file, 
         :multipart => true
      }
      start_time = Time.now.to_f
      resp = @rest_client[ make_url( "source" ) ].post opts, :authorization => @authtoken
      dump_time( "post", start_time )
      json = JSON.parse(resp)
      return json[ 0 ]
   end

   def put( request, payload )
      start_time = Time.now.to_f
      resp = @rest_client[ make_url( request ) ].put payload.to_json, :authorization => @authtoken, :content_type => "application/json"
      dump_time( "put", start_time )
      return resp
   end

   def delete( request, in_workspace=true )
      start_time = Time.now.to_f
      url = in_workspace ? make_url( request ) : request   
      resp =  @rest_client[ url ].delete :authorization => @authtoken
      dump_time( "delete", start_time )
      return resp
   end

   def make_url( request )
     "#{@workspace}/#{request}"
   end

   def dump_time( what, start_time )
     #puts "#{what}: %0.2f mS" % ( ( Time.now.to_f - start_time ) * 1000 )
   end
end