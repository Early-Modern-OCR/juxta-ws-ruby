require 'juxta/connection'
require 'juxta/utilities'


# Author::    Nick Laiacona  (mailto:nick@performantsoftware.com), Lou Foster, Dave Goldstein
# Copyright:: Copyright (c) 2013
# License::   Distributes under Apache License


# This class provides the Ruby interface to the JuxtaWS REST web service. 
class Juxta

  # Set to true to enable logging.
  attr_accessor :logging
  
  # The connection object for this Juxta instance.
  attr_reader :connection

  # Initialize a Juxta interface with optional authentication. 
  # 
  # @param [String] URL of the JuxtaWS server to connect to.
  # @param [String] username if server require authentication.
  # @param [String] password if server require authentication.
  # @return [Connection] 
  def initialize( url, username=nil, password=nil )
    @logging = false
    @connection = Connection.new( url, username, password ) 
  end

  # The name of the currently selected workspace. Default is "public".
  # @return [String] The name of the current workspace. 
  def workspace()
    @connection.workspace
  end
  
  # Select a workspace to operate in.
  #
  # @param [String] workspace_name this is the name of the workspace.
  # @return [Object] true if selection suceeded, false otherwise.
  def select_workspace(workspace_name)
    workspaces = list_workspaces()
    workspace_names = workspaces.map { |workspace|
      workspace["name"]
    }
    
    if workspace_names.include? workspace_name
      @connection.workspace = workspace_name
      return true
    else
      return false
    end    
  end

  # Lists the workspaces available on this server.
  #
  # @return [Array] List of workspace names.
  def list_workspaces
    log_message( "Listing workspaces..." ) unless @logging == false
    ws_list = @connection.get( "workspace", false )
    return ws_list
  end

  # Create a new workspace.
  #
  # @param [String] Name of the workspace to create. Must be unique to this server.  
  # @return [String] If successful, the created workspace's id.
  def create_workspace( workspace_id )
    log_message( "Creating workspace #{workspace_id} ..." ) unless @logging == false
    json = { "name" => workspace_id, "description" => "the description for #{workspace_id}" }
    workspace_id = @connection.post( "workspace", json, false )
    return workspace_id
  end


  # Delete a new workspace and everything in it.
  #
  # @param [String] Name of the workspace to delete. 
  # @return [Object] True if successful, false otherwise.
  def delete_workspace( workspace_id )
    log_message( "Deleting workspace #{workspace_id} ..." ) unless @logging == false
    resp = @connection.delete( "workspace/#{workspace_id}", false )
    if resp['status'] == 'FAILED'
       error_message( "failed to delete asset: #{asset_id}")
       return false
    end
    return true
  end

  # List the witnesses in this workspace. Witnesses are the transformed version of the sources.
  #
  # @return [Array] An array of hashes with summary information about each witness.
  def list_witnesses
    log_message( "Listing witnesses..." ) unless @logging == false
    witness_list = @connection.get( "witness" )
    return witness_list
  end

  # Get full information about a given witness.
  #
  # @param [String,Integer] witness_id Identifier of the witness to retrieve. 
  # @return [Hash] A hash with complete information about the witness, including full text.
  def get_witness( witness_id )
    log_message( "Getting witness #{witness_id}..." ) unless @logging == false
    resp = @connection.get( "witness/#{witness_id}" )
    return resp
  end
  
  
  # Retrieve a text fragment from a given witness.
  #
  # @param [String,Integer] witness_id Identifier of the witness. 
  # @param [String,Integer] start_point Starting offset of the fragment. 
  # @param [String,Integer] end_point Ending offset of the fragment. 
  # @return [String] A string containing the text fragment, if found.
  def get_witness_fragment( witness_id, start_point, end_point )
    log_message( "Getting witness #{witness_id}..." ) unless @logging == false
    @connection.get_html( "witness/#{witness_id}.txt?range=#{start_point},#{end_point}" )
  end

  # Change the name of the witness.
  #
  # @param [String,Integer] witness_id Identifier of the witness. 
  # @param [String,Integer] new_name The new name for the witness. 
  # @return [Hash] 
  def rename_witness( witness_id, new_name )
    log_message( "Renaming witness #{witness_id} to #{new_name}..." ) unless @logging == false
    json = { 'name' => new_name }
    resp = @connection.put( "witness/#{witness_id}", json )
    return resp
  end

  # List the sources in this workspace.
  #
  # @return [Array] An array of hashes with summary information about each source.
  def list_sources
    log_message( "Listing sources..." ) unless @logging == false
    source_list = @connection.get( "source" )
    return source_list
  end

  # Create a new XSLT on the server.
  # 
  # @param [String] name A display name for this XSLT.
  # @param [String] xslt XML string for the XSLT.
  # @return [String] An identifier for the newly created XSLT.
  def create_xslt( name, xslt )
    @connection.post("xslt", {:name=>name, :xslt=>xslt } )
  end

  # List the XSL stylesheets in this workspace.
  #
  # @return [Array] An array of hashes with summary information about each XSLT.
  def list_xslt
    log_message( "Listing xslt..." ) unless @logging == false
    xslt_list = @connection.get( "xslt" )
    return xslt_list
  end
  
  # Get full information about a given comparison set.
  #
  # @param [String,Integer] set_id Identifier of a comparison set. 
  # @return [Hash] A hash with complete information about the comparison set, including a list of witnesses.
  def get_set( set_id )
    log_message( "Getting set #{set_id}..." ) unless @logging == false
    @connection.get( "set/#{set_id}" )
  end

  def create_annotation( set_id, witness_id, json )
     asset_id = "set/#{set_id}/witness/#{witness_id}/annotation"
     log_message( "Posting annotations to #{asset_id}..." ) unless @logging == false   
     resp = @connection.post(asset_id, json)
     return resp
  end

  # List the annotations applied to a given witness in a comparison set.
  #
  # @param [String,Integer] set_id Identifier of a comparison set. 
  # @param [String,Integer] witness_id Identifier of a witness. 
  # @return [Array] An array of hashes containing annotation data.
  def list_annotations( set_id, witness_id )
    asset_id = "set/#{set_id}/witness/#{witness_id}"
    log_message( "Listing annotations for #{asset_id}..." ) unless @logging == false
    annotation_list = @connection.get( "#{asset_id}/annotation" )
    return annotation_list
  end

  # Retrieve information about a specific annotation.
  #
  # @param [String,Integer] set_id Identifier of a comparison set. 
  # @param [String,Integer] witness_id Identifier of a witness. 
  # @param [String,Integer] annotation_id Identifier of the specified annotation. 
  # @return [Hash] A hash containing the annotation data.  
  def get_annotation( set_id, witness_id, annotation_id )
    log_message( "Getting annotation #{annotation_id}..." ) unless @logging == false
    @connection.get( "set/#{set_id}/witness/#{witness_id}/annotation/#{annotation_id}?content=YES" )
  end

  def create_alignment( set_id, json )
     asset_id = "set/#{set_id}/alignment"
     log_message( "Posting alignments to #{asset_id}..." ) unless @logging == false   
     resp = @connection.post(asset_id, json)
     return resp
  end

  # List the alignments for a given comparison set.
  #
  # @param [String,Integer] set_id Identifier of a comparison set. 
  # @return [Array] An array of hashes containing alignment data.  
  def list_alignments( set_id )
    asset_id = "set/#{set_id}"
    log_message( "Listing alignments for #{asset_id}..." ) unless @logging == false
    @connection.get( "#{asset_id}/alignment" )
  end

  # Get full information about a given alignment.
  #
  # @param [String,Integer] set_id Identifier of a comparison set. 
  # @param [String,Integer] alignment_id Identifier of an alignment. 
  # @return [Hash] A hash with complete information about the alignment, including text fragments.  
  def get_alignment( set_id, alignment_id )
    asset_id = "set/#{set_id}/alignment/#{alignment_id}"
    log_message( "Getting alignment #{asser_id}..." ) unless @logging == false
    @connection.get( "#{asset_id}" )
  end

  def delete_asset( asset_id )

    log_message( "Deleting asset #{asset_id} ..." ) unless @logging == false
    resp = @connection.delete( asset_id )
    if resp['status'] == 'FAILED'
       error_message( "failed to delete asset: #{asset_id}")
       return false
    end
    return true
  end

  # Delete the specified witness.
  #
  # @param [String,Integer] witness_id Identifier of the witness.
  # @return [Object] True if successful, false otherwise.
  def delete_witness( witness_id )
     return delete_asset( "witness/#{witness_id}" )
  end

  # Delete the specified source.
  #
  # @param [String,Integer] source_id Identifier of the source.
  # @return [Object] True if successful, false otherwise.
  def delete_source( source_id )
    return delete_asset( "source/#{source_id}" )
  end

  # Delete the specified comparison set.
  #
  # @param [String,Integer] set_id Identifier of the comparison set.
  # @return [Object] True if successful, false otherwise.
  def delete_set( set_id )
    return delete_asset( "set/#{set_id}" )
  end

  # Delete the specified annotation from a given comparison set witness.
  #
  # @param [String,Integer] set_id Identifier of the comparison set.
  # @param [String,Integer] witness_id Identifier of the witness.
  # @param [String,Integer] annotation_id Identifier of the annotation.
  # @return [Object] True if successful, false otherwise.
  def delete_annotation( set_id, witness_id, annotation_id )
    return delete_asset( "set/#{set_id}/witness/#{witness_id}/annotation/#{annotation_id}" )
  end

  # Delete the specified alignment from a given comparison set.
  #
  # @param [String,Integer] set_id Identifier of the comparison set.
  # @param [String,Integer] alignment_id Identifier of a given alignment.
  # @return [Object] True if successful, false otherwise.
  def delete_alignment( set_id, alignment_id )
    return delete_asset( "set/#{set_id}/alignment/#{alignment_id}" )
  end

  # Upload a file from local disk to the server.
  #
  # @param [String] file_name Local path to the file to upload.
  # @return [String] Identifier of uploaded source if successful, otherwise nil.
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

  # Command the server to create source files from the provided array of hashes.
  #
  # @param [Arrray] source_array Array of hashes describing the sources to be created.
  # @return [Array] Identifiers of the sources if successful, otherwise nil.  
  def create_sources( source_array )
    log_message( "Creating sources from JSON data..." ) unless @logging == false
    resp = @connection.post( "source", source_array )
    JSON.parse(resp) 
  end
    
  # Command the server to obtain an XML source file from the specified URL.
  #
  # @param [String] url URL of the XML source file to grab.
  # @return [String] Identifier of the obtained source if successful, otherwise nil.
  def obtain_source_from_url( url )
    id = make_guid()
    log_message( "Downloading #{url} as #{id} ..." ) unless @logging == false
    resp = @connection.post( "source", [{name: id, type: 'url', contentType: 'xml', data: url}] )
    parsed = JSON.parse(resp) 
    if parsed.length > 0
      parsed[0]
    else
      nil
    end
  end

  # Transform the specified source into a witness using the associated XSLT.
  #
  # @param [String,Integer] source_id Identifier of the source.
  # @return [String] Identifier of the resultant witness.
  def transform_source( source_id )

    log_message( "Transforming #{source_id} ..." ) unless @logging == false
    json = { 'source' => source_id, 'finalName' => make_guid() }
    wit_id = @connection.post( "transform", json )
    return wit_id
  end

  # List the comparison sets in this workspace.
  #
  # @return [Array] An array of hashes with summary information about each comparison set.
  def list_sets
    log_message( "Listing sets..." ) unless @logging == false
    set_list = @connection.get( "set" )
    return set_list
  end

  # Group the specified witnesses into a new comparison set.
  #
  # @param [Array] witness_ids An array of witness identifiers.
  # @return [String] Identifier of the resultant comparison set.
  def make_set( witness_ids )
    log_message( "Creating witness set ..." ) unless @logging == false
    set = { 'name' => make_guid(), 'witnesses' => witness_ids }
    set_id = @connection.post( "set", set )
    return set_id
  end

  # Tokenize the specified comparison set. Returns 
  # immediately, use get_status(task_id) to check the status of tokenization. Tokens are 
  # accessible as annotations of type 'token'. 
  #
  # @param [String,Integer] set_id Identifier of the comparison set.
  # @return [String] An identifier for the server task.
  def async_tokenize_set( set_id )
     log_message( "Tokenizing witness set #{set_id}..." ) unless @logging == false
     @connection.post( "set/#{set_id}/tokenize", nil)
  end

  # Tokenize the specified comparison set. Tokens are accessible as annotations of type 'token'.
  #
  # @param [String,Integer] set_id Identifier of the comparison set.
  # @return [Object] True if successful, false otherwise.
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

  # Collate the specified comparison set. Returns immediately, use 
  # get_status(task_id) to check the status of collation.
  #
  # @param [String,Integer] set_id Identifier of the comparison set.
  # @return [String] An identifier for the server task.
  def async_collate_set( set_id )
     log_message( "Collating witness set #{set_id}..." ) unless @logging == false
     @connection.post( "set/#{set_id}/collate", nil)
  end

  # Collate the specified comparison set and wait for the response from server.
  #
  # @param [String,Integer] set_id Identifier of the target comparison set.
  # @return [Object] True if successful, false otherwise.
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

  # Search the current workspace for the specified phrase. Server must have search indexing enabled.
  #
  # @param [String] query The phrase to search for within the workspace.
  # @return [Array] An array of objects that detail the search results.
  def search( query )
    log_message( "Searching for #{query}..." ) unless @logging == false
    resp = @connection.get("search?q=#{query}")
    return resp
  end

  # Retrieve the status of a server side task. 
  #
  # @param [String,Integer] task_id An identifier for a server side task.
  # @return [String] A status code. Possible codes are: PENDING, PROCESSING, COMPLETE, CANCEL_REQUESTED, CANCELED, FAILED.
  def get_status( task_id )
    log_message( "Getting status for #{task_id}..." ) unless @logging == false
    resp = @connection.get("task/#{task_id}/status")
    return resp['status']
  end

  def async_get_as_html( asset_id )
    log_message( "Getting html #{asset_id}..." ) unless @logging == false
    resp = @connection.get_html( asset_id )
    if resp.include?('RENDERING') == true
      return resp.split( ' ' )[ 1 ]
    end
    return nil
  end

  # Creates a URL for the heatmap of a given base text in a comparison set.
  #
  # @param [String, Integer] set_id Identifier of a comparison set.
  # @param [String, Integer] base_id Identifier of a base text.
  # @return [String] URL to the heatmap visualization of the given base text.
  def get_heatmap_url( set_id, base_id )
    @connection.make_full_url( "set/#{set_id}/view?mode=heatmap&base=#{base_id}" )    
  end
  
  # Creates a URL for a side-by-side comparison of two witnesses in a comparison set.
  #
  # @param [String, Integer] set_id Identifier of a comparison set.
  # @param [String, Integer] witness_a Identifier of the first witness.
  # @param [String, Integer] witness_b Identifier of the second witness.
  # @return [String] URL to the side-by-side visualization.
  def get_side_by_side_url( set_id, witness_a, witness_b )
    @connection.make_full_url( "set/#{set_id}/view?mode=sidebyside&docs=#{witness_a},#{witness_b}" )    
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
    resp = @connection.get( "#{asset_id}/info", false )
    return resp
  end

  def get_usage( asset_id )
    log_message( "Getting usage for #{asset_id}..." ) unless @logging == false
    resp = @connection.get( "#{asset_id}/usage" )
    return resp
  end

  # Get the specified XSLT resource from server.
  #
  # @param [String,Integer] asset_id The identifier of the specified XSLT.
  # @return [String] XML for the specified XSLT.
  def get_xslt( asset_id )
    log_message( "Getting xslt #{asset_id}..." ) unless @logging == false
    @connection.get_html( "xslt/#{asset_id}" )
  end

  # TEI Parallel segmentation export
  def export( set_id, base_id )
    log_message( "Exporting set #{set_id}..." ) unless @logging == false
    resp = @connection.get_xml( "set/#{set_id}/export?mode=teips&base=#{base_id}&sync" )
    return resp
  end

  # Create an uncollated comparison set from an array of local files.
  # 
  # @param [Array] file_list An array of paths to local files to upload. 
  # @return [Array] Array of resultant source identifiers. 
  # @return [Array] Array of resultant witness identifiers. 
  # @return [String] The identifier for the resultant comparison set. 
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

    source_list.each do |src_id|
      status = delete_source( src_id )
      return false unless status == true
    end

    return true
  end


end