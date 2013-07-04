require 'lib/connection'
require 'lib/utilities'

class Juxta

  attr :logging
  attr_reader :connection

  def initialize( url, workspace )
    @logging = true
    @connection = Connection.new( url, workspace, "", "" ) 
  end

  #
  # workspace behavior
  #
  def list_workspaces
    log_message( "Listing workspaces..." ) unless @logging == false
    ws_list = @connection.get( "workspace" )
    return ws_list
  end

  def create_workspace( workspace_id )
    log_message( "Creating workspace #{workspace_id} ..." ) unless @logging == false
    json = { "name" => workspace_id, "description" => "the description for #{workspace_id}" }
    workspace_id = @connection.post( "workspace", json )
    return workspace_id
  end

  def delete_workspace( workspace_id )
    return delete_asset( "workspace/#{workspace_id}" )
  end

  #
  # witness behavior
  #

  def list_witnesses
    log_message( "Listing witnesses..." ) unless @logging == false
    witness_list = @connection.get( "witness" )
    return witness_list
  end

  def get_witness( witness_id )
    log_message( "Getting witness #{witness_id}..." ) unless @logging == false
    resp = @connection.get( "witness/#{witness_id}" )
    return resp
  end

  def rename_witness( witness_id, new_name )
    log_message( "Renaming witness #{witness_id} to #{new_name}..." ) unless @logging == false
    json = { 'name' => new_name }
    resp = @connection.put( "witness/#{witness_id}", json )
    return resp
  end

  #
  # source behavior
  #

  def list_sources
    log_message( "Listing sources..." ) unless @logging == false
    source_list = @connection.get( "source" )
    return source_list
  end

  #
  # xslt behavior
  #

  def create_xslt( json )
     asset_id = "xslt"
     resp = @connection.post(asset_id, json)
     return resp
  end

  def list_xslt
    log_message( "Listing xslt..." ) unless @logging == false
    xslt_list = @connection.get( "xslt" )
    return xslt_list
  end

  #
  # annotation behavior
  #

  def create_annotation( set_id, witness_id, json )
     asset_id = "set/#{set_id}/witness/#{witness_id}/annotation"
     log_message( "Posting annotations to #{asset_id}..." ) unless @logging == false   
     resp = @connection.post(asset_id, json)
     return resp
  end

  def list_annotations( set_id, witness_id )
    asset_id = "set/#{set_id}/witness/#{witness_id}"
    log_message( "Listing annotations for #{asset_id}..." ) unless @logging == false
    annotation_list = @connection.get( "#{asset_id}/annotation" )
    return annotation_list
  end

  def get_annotation( annotation_id )
    log_message( "Getting annotation #{annotation_id}..." ) unless @logging == false
    resp = @connection.get( "#{annotation_id}?content=YES" )
    return resp
  end

  #
  # alignmant behavior
  #

  def create_alignment( set_id, json )
     asset_id = "set/#{set_id}/alignment"
     log_message( "Posting alignments to #{asset_id}..." ) unless @logging == false   
     resp = @connection.post(asset_id, json)
     return resp
  end

  def list_alignments( set_id )
    asset_id = "set/#{set_id}"
    log_message( "Listing alignments for #{asset_id}..." ) unless @logging == false
    annotation_list = @connection.get( "#{asset_id}/alignment" )
    return annotation_list
  end

  def get_alignment( set_id, alignment_id )
    asset_id = "set/#{set_id}/alignment/#{alignment_id}"
    log_message( "Getting alignment #{asser_id}..." ) unless @logging == false
    resp = @connection.get( "#{asset_id}" )
    return resp
  end

  #
  # delete behavior
  #

  def delete_asset( asset_id )

    log_message( "Deleting asset #{asset_id} ..." ) unless @logging == false
    resp = @connection.delete( asset_id )
    if resp['status'] == 'FAILED'
       error_message( "failed to delete asset: #{asset_id}")
       return false
    end
    return true
  end

  def delete_witness( witness_id )
     return delete_asset( "witness/#{witness_id}" )
  end

  def delete_source( source_id )
    return delete_asset( "source/#{source_id}" )
  end

  def delete_set( set_id )
    return delete_asset( "set/#{set_id}" )
  end

  def delete_annotation( set_id, witness_id, annotation_id )
    return delete_asset( "set/#{set_id}/witness/#{witness_id}/annotation/#{annotation_id}" )
  end

  def delete_alignment( set_id, alignment_id )
    return delete_asset( "set/#{set_id}/alignment/#{alignment_id}" )
  end

  #
  # upload behavior
  #

  def upload_source( file_name )

     id = make_guid()
     log_message( "Uploading #{file_name} as #{id} ..." ) unless @logging == false
     src_id = @connection.upload_file( id, "text/xml", open( file_name ))

     srcs = @connection.get("source")
     srcs.each do |src|
       if src['id'] == src_id
         log_message( "successfully uploaded file: #{file_name} (#{src['name']})" ) unless @logging == false
         return src_id
       end

     end

     error_message( "failed to upload file: #{file_name}")
     return nil
  end

  #
  # transform behavior
  #

  def transform_source( file_id )

    log_message( "Transforming #{file_id} ..." ) unless @logging == false
    json = { 'source' => file_id, 'finalName' => make_guid() }
    wit_id = @connection.post( "transform", json )
    return wit_id
  end

  #
  # witness set behavior
  #

  def list_sets
    log_message( "Listing sets..." ) unless @logging == false
    set_list = @connection.get( "set" )
    return set_list
  end

  def make_set( witness_ids )
    log_message( "Creating witness set ..." ) unless @logging == false
    set = { 'name' => make_guid(), 'witnesses' => witness_ids }
    set_id = @connection.post( "set", set )
    return set_id
  end

  def async_tokenize_set( set_id )
     log_message( "Tokenizing witness set #{set_id}..." ) unless @logging == false
     task_id = @connection.post( "set/#{set_id}/tokenize", nil)
     return task_id
  end

  def tokenize_set( set_id )
    task_id = async_tokenize_set( set_id )
    while true do
      sleep(2.0)
      resp = get_status( task_id )
      case resp
        when 'COMPLETE'
          return true

        when 'FAILED'
           error_message( "failed to tokenize set: #{set_id}")
           return false
      end
    end
  end

  def async_collate_set( set_id )
     log_message( "Collating witness set #{set_id}..." ) unless @logging == false
     task_id = @connection.post( "set/#{set_id}/collate", nil)
     return task_id
  end

  def collate_set( set_id )
    task_id = async_collate_set( set_id )
    while true do
      sleep(2.0)
      resp = get_status( task_id )
      case resp
        when 'COMPLETE'
          return true

        when 'FAILED'
          error_message( "failed to tokenize set: #{set_id}")
          return false
      end
    end
  end

  #
  # Search behavior
  #
  def search( query )
    log_message( "Searching for #{query}..." ) unless @logging == false
    resp = @connection.get("search?q=#{query}")
    return resp
  end

  #
  # task status behavior
  #

  def get_status( task_id )
    log_message( "Getting status for #{task_id}..." ) unless @logging == false
    resp = @connection.get("task/#{task_id}/status")
    return resp['status']
  end

  #
  # get asset behavior
  #

  def async_get_as_html( asset_id )
    log_message( "Getting html #{asset_id}..." ) unless @logging == false
    resp = @connection.get_html( asset_id )
    if resp.include?('RENDERING') == true
      return resp.split( ' ' )[ 1 ]
    end
    return nil
  end

  def get_as_html( asset_id )
     task_id = async_get_as_html( asset_id )
     if task_id.nil? == false
        while true do
           sleep(2.0)
           resp = get_status( task_id )
           case resp
           when 'COMPLETE'
              return @connection.get_html( asset_id )

           when 'FAILED'
              error_message( "failed to get html asset: #{asset_id}")
              return false
           end
        end
     end
     return resp
  end

  def async_get_as_json( asset_id )
    log_message( "Getting json #{asset_id}..." ) unless @logging == false
    resp = @connection.get( asset_id )
    if resp['status'] == 'RENDERING'
      return resp['taskId']
    end
    return nil
  end

  def get_as_json( asset_id )
     task_id = async_get_as_json( asset_id )
     if task_id.nil? == false
        while true do
           sleep(2.0)
           resp = get_status( task_id )
           case resp
           when 'COMPLETE'
              return @connection.get( asset_id )

           when 'FAILED'
              error_message( "failed to get json asset: #{asset_id}")
              return false
           end
        end
     end
     return false
  end

  def get_info( asset_id )
    log_message( "Getting info for #{asset_id}..." ) unless @logging == false
    resp = @connection.get( "#{asset_id}/info" )
    return resp
  end

  def get_usage( asset_id )
    log_message( "Getting usage for #{asset_id}..." ) unless @logging == false
    resp = @connection.get( "#{asset_id}/usage" )
    return resp
  end

  def get_xslt( asset_id )
    log_message( "Getting xslt #{asset_id}..." ) unless @logging == false
    resp = @connection.get_html( "xslt/#{asset_id}" )
    return resp
  end

  #
  # TEI Parallel segmentation export
  #

  def export( set_id, base_id )
    log_message( "Exporting set #{set_id}..." ) unless @logging == false
    resp = @connection.get_xml( "set/#{set_id}/export?mode=teips&base=#{base_id}&sync" )
    return resp
  end

  # 
  # Edition starter
  # 

  def edition( set_id, title, line_freq, base_id, wit_siglum_map )
     data = {}
     data['title'] = title
     data['lineFrequency'] = line_freq
     data['numberBlankLines'] = false
     witnesses = []
     wit_siglum_map.each do |id, siglum|
        wit = {"id"=> id, "include"=>true, "base"=>(id == base_id), "siglum"=>siglum}
        witnesses << wit
     end
     data['witnesses'] = witnesses

     log_message( "Exporting edition for set #{set_id}..." ) unless @logging == false   
     resp = @connection.post("set/#{set_id}/edition", data)

     # wait for task to complete
     parsed = JSON.parse(resp)
     token = parsed['token']
     task = parsed['taskId']

     while true do
      sleep(2.0)
      resp = get_status( task )
      puts resp
      case resp
        when 'COMPLETE'
          break

        when 'FAILED'
          error_message( "failed to tokenize set: #{set_id}")
          return false
      end
    end

    # now request the HTML edition and pass along the token
    html = @connection.get_html("set/#{set_id}/edition?token=#{token}&format=html")
    return html

  end

  #
  # convience methods
  #

  def create_witness_set( file_list )

    src_ids = []
    wit_ids = []

    file_list.each do |file|

      # create source
      src_id = upload_source( file )
      src_ids.push( src_id )

      # xform to witness
      wit_id = transform_source( src_id )
      wit_ids.push( wit_id )

    end

    # create set from witnesses
    set_id = make_set( wit_ids )

    return src_ids, wit_ids, set_id
  end

  def destroy_witness_set( source_list, witness_list )

    witness_list.each do |wit_id|
      status = delete_witness( wit_id )
      return false unless status == true
    end

    source_list.each do |src_id|
      status = delete_source( src_id )
      return false unless status == true
    end

    return true
  end


end