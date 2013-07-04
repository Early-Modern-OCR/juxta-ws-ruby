require './utils/connection'

#
# workspace behavior
#
def jx_list_workspaces( connection, logging )
  log_message( "Listing workspaces..." ) unless logging == false
  ws_list = connection.get( "workspace" )
  return ws_list
end

def jx_create_workspace( connection, workspace_id, logging )
  log_message( "Creating workspace #{workspace_id} ..." ) unless logging == false
  json = { "name" => workspace_id, "description" => "the description for #{workspace_id}" }
  workspace_id = connection.post( "workspace", json )
  return workspace_id
end

def jx_delete_workspace( connection, workspace_id, logging )
  return jx_delete_asset( connection, "workspace/#{workspace_id}", logging )
end

#
# witness behavior
#

def jx_list_witnesses( connection, logging )
  log_message( "Listing witnesses..." ) unless logging == false
  witness_list = connection.get( "witness" )
  return witness_list
end

def jx_get_witness( connection, witness_id, logging )
  log_message( "Getting witness #{witness_id}..." ) unless logging == false
  resp = connection.get( "witness/#{witness_id}" )
  return resp
end

def jx_rename_witness( connection, witness_id, new_name, logging )
  log_message( "Renaming witness #{witness_id} to #{new_name}..." ) unless logging == false
  json = { 'name' => new_name }
  resp = connection.put( "witness/#{witness_id}", json )
  return resp
end

#
# source behavior
#

def jx_list_sources( connection, logging )
  log_message( "Listing sources..." ) unless logging == false
  source_list = connection.get( "source" )
  return source_list
end

#
# xslt behavior
#

def jx_create_xslt( connection, json, logging )
   asset_id = "xslt"
   resp = connection.post(asset_id, json)
   return resp
end

def jx_list_xslt( connection, logging )
  log_message( "Listing xslt..." ) unless logging == false
  xslt_list = connection.get( "xslt" )
  return xslt_list
end

#
# annotation behavior
#

def jx_create_annotation( connection, set_id, witness_id, json, logging )
   asset_id = "set/#{set_id}/witness/#{witness_id}/annotation"
   log_message( "Posting annotations to #{asset_id}..." ) unless logging == false   
   resp = connection.post(asset_id, json)
   return resp
end

def jx_list_annotations( connection, set_id, witness_id, logging )
  asset_id = "set/#{set_id}/witness/#{witness_id}"
  log_message( "Listing annotations for #{asset_id}..." ) unless logging == false
  annotation_list = connection.get( "#{asset_id}/annotation" )
  return annotation_list
end

def jx_get_annotation( connection, annotation_id, logging )
  log_message( "Getting annotation #{annotation_id}..." ) unless logging == false
  resp = connection.get( "#{annotation_id}?content=YES" )
  return resp
end

#
# alignmant behavior
#

def jx_create_alignment( connection, set_id, json, logging )
   asset_id = "set/#{set_id}/alignment"
   log_message( "Posting alignments to #{asset_id}..." ) unless logging == false   
   resp = connection.post(asset_id, json)
   return resp
end

def jx_list_alignments( connection, set_id, logging )
  asset_id = "set/#{set_id}"
  log_message( "Listing alignments for #{asset_id}..." ) unless logging == false
  annotation_list = connection.get( "#{asset_id}/alignment" )
  return annotation_list
end

def jx_get_alignment( connection, set_id, alignment_id, logging )
  asset_id = "set/#{set_id}/alignment/#{alignment_id}"
  log_message( "Getting alignment #{asser_id}..." ) unless logging == false
  resp = connection.get( "#{asset_id}" )
  return resp
end

#
# delete behavior
#

def jx_delete_asset( connection, asset_id, logging )

  log_message( "Deleting asset #{asset_id} ..." ) unless logging == false
  resp = connection.delete( asset_id )
  if resp['status'] == 'FAILED'
     error_message( "failed to delete asset: #{asset_id}")
     return false
  end
  return true
end

def jx_delete_witness( connection, witness_id, logging )
   return jx_delete_asset( connection, "witness/#{witness_id}", logging )
end

def jx_delete_source( connection, source_id, logging )
  return jx_delete_asset( connection, "source/#{source_id}", logging )
end

def jx_delete_set( connection, set_id, logging )
  return jx_delete_asset( connection, "set/#{set_id}", logging )
end

def jx_delete_annotation( connection, set_id, witness_id, annotation_id, logging )
  return jx_delete_asset( connection, "set/#{set_id}/witness/#{witness_id}/annotation/#{annotation_id}", logging )
end

def jx_delete_alignment( connection, set_id, alignment_id, logging )
  return jx_delete_asset( connection, "set/#{set_id}/alignment/#{alignment_id}", logging )
end

#
# upload behavior
#

def jx_upload_source( connection, file_name, logging )

   id = make_guid( )
   log_message( "Uploading #{file_name} as #{id} ..." ) unless logging == false
   src_id = connection.upload_file( id, "text/xml", open( file_name ))

   srcs = connection.get("source")
   srcs.each do |src|
     if src['id'] == src_id
       log_message( "successfully uploaded file: #{file_name} (#{src['name']})" ) unless logging == false
       return src_id
     end

   end

   error_message( "failed to upload file: #{file_name}")
   return nil
end

#
# transform behavior
#

def jx_transform_source( connection, file_id, logging )

  log_message( "Transforming #{file_id} ..." ) unless logging == false
  json = { 'source' => file_id, 'finalName' => make_guid() }
  wit_id = connection.post( "transform", json )
  return wit_id
end

#
# witness set behavior
#

def jx_list_sets( connection, logging )
  log_message( "Listing sets..." ) unless logging == false
  set_list = connection.get( "set" )
  return set_list
end

def jx_make_set( connection, witness_ids, logging )
  log_message( "Creating witness set ..." ) unless logging == false
  set = { 'name' => make_guid(), 'witnesses' => witness_ids }
  set_id = connection.post( "set", set )
  return set_id
end

def jx_async_tokenize_set( connection, set_id, logging )
   log_message( "Tokenizing witness set #{set_id}..." ) unless logging == false
   task_id = connection.post( "set/#{set_id}/tokenize", nil)
   return task_id
end

def jx_tokenize_set( connection, set_id, logging )
  task_id = jx_async_tokenize_set( connection, set_id, logging )
  while true do
    sleep(2.0)
    resp = jx_get_status( connection, task_id, logging )
    case resp
      when 'COMPLETE'
        return true

      when 'FAILED'
         error_message( "failed to tokenize set: #{set_id}")
         return false
    end
  end
end

def jx_async_collate_set( connection, set_id, logging )
   log_message( "Collating witness set #{set_id}..." ) unless logging == false
   task_id = connection.post( "set/#{set_id}/collate", nil)
   return task_id
end

def jx_collate_set( connection, set_id, logging )
  task_id = jx_async_collate_set( connection, set_id, logging )
  while true do
    sleep(2.0)
    resp = jx_get_status( connection, task_id, logging )
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
def jx_search( connection, query, logging )
  log_message( "Searching for #{query}..." ) unless logging == false
  resp = connection.get("search?q=#{query}")
  return resp
end

#
# task status behavior
#

def jx_get_status( connection, task_id, logging )
  log_message( "Getting status for #{task_id}..." ) unless logging == false
  resp = connection.get("task/#{task_id}/status")
  return resp['status']
end

#
# get asset behavior
#

def jx_async_get_as_html( connection, asset_id, logging )
  log_message( "Getting html #{asset_id}..." ) unless logging == false
  resp = connection.get_html( asset_id )
  if resp.include?('RENDERING') == true
    return resp.split( ' ' )[ 1 ]
  end
  return nil
end

def jx_get_as_html( connection, asset_id, logging )
   task_id = jx_async_get_as_html( connection, asset_id, logging )
   if task_id.nil? == false
      while true do
         sleep(2.0)
         resp = jx_get_status( connection, task_id, logging )
         case resp
         when 'COMPLETE'
            return connection.get_html( asset_id )

         when 'FAILED'
            error_message( "failed to get html asset: #{asset_id}")
            return false
         end
      end
   end
   return resp
end

def jx_async_get_as_json( connection, asset_id, logging )
  log_message( "Getting json #{asset_id}..." ) unless logging == false
  resp = connection.get( asset_id )
  if resp['status'] == 'RENDERING'
    return resp['taskId']
  end
  return nil
end

def jx_get_as_json( connection, asset_id, logging )
   task_id = jx_async_get_as_json( connection, asset_id, logging )
   if task_id.nil? == false
      while true do
         sleep(2.0)
         resp = jx_get_status( connection, task_id, logging )
         case resp
         when 'COMPLETE'
            return connection.get( asset_id )

         when 'FAILED'
            error_message( "failed to get json asset: #{asset_id}")
            return false
         end
      end
   end
   return false
end

def jx_get_info( connection, asset_id, logging )
  log_message( "Getting info for #{asset_id}..." ) unless logging == false
  resp = connection.get( "#{asset_id}/info" )
  return resp
end

def jx_get_usage( connection, asset_id, logging )
  log_message( "Getting usage for #{asset_id}..." ) unless logging == false
  resp = connection.get( "#{asset_id}/usage" )
  return resp
end

def jx_get_xslt( connection, asset_id, logging )
  log_message( "Getting xslt #{asset_id}..." ) unless logging == false
  resp = connection.get_html( "xslt/#{asset_id}" )
  return resp
end

#
# TEI Parallel segmentation export
#

def jx_export( connection, set_id, base_id, logging )
  log_message( "Exporting set #{set_id}..." ) unless logging == false
  resp = connection.get_xml( "set/#{set_id}/export?mode=teips&base=#{base_id}&sync" )
  return resp
end

# 
# Edition starter
# 

def jx_edition( connection, set_id, title, line_freq, base_id, wit_siglum_map, logging )
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
   
   log_message( "Exporting edition for set #{set_id}..." ) unless logging == false   
   resp = connection.post("set/#{set_id}/edition", data)
   
   # wait for task to complete
   parsed = JSON.parse(resp)
   token = parsed['token']
   task = parsed['taskId']
   
   while true do
    sleep(2.0)
    resp = jx_get_status( connection, task, logging )
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
  html = connection.get_html("set/#{set_id}/edition?token=#{token}&format=html")
  return html
   
end

#
# higher level helpers for testing...
#

def jx_create_witness_set( connection, file_list, logging )

  src_ids = []
  wit_ids = []

  file_list.each do |file|

    # create source
    src_id = jx_upload_source( connection, file, logging )
    src_ids.push( src_id )

    # xform to witness
    wit_id = jx_transform_source( connection, src_id, logging )
    wit_ids.push( wit_id )

  end

  # create set from witnesses
  set_id = jx_make_set( connection, wit_ids, logging )

  return src_ids, wit_ids, set_id
end

def jx_destroy_witness_set( connection, source_list, witness_list, logging )

  witness_list.each do |wit_id|
    status = jx_delete_witness( connection, wit_id, logging )
    return false unless status == true
  end

  source_list.each do |src_id|
    status = jx_delete_source( connection, src_id, logging )
    return false unless status == true
  end

  return true
end
