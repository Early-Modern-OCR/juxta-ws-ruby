require 'uuidtools'
require 'restclient'
require 'json'

# coordinate access to stdout...
Log_sem = Mutex.new

def log_message( message )
   Log_sem.synchronize {
      puts "#{Time.now.strftime("%T")}-#{Thread.current.object_id % 10000}: #{message}"
   }
end

def error_message( message )
   Log_sem.synchronize {
      puts( "#{Time.now.strftime("%T")}-#{Thread.current.object_id % 10000}: ERROR ** #{message} **" )
   }
end

def make_guid( )
  UUIDTools::UUID.random_create.to_s.gsub(/-/, '')
end

def get_filelist( dir )
  files = Dir.entries( dir )
  files = files.map { |f| "#{dir}/#{f}"}
  files = files.delete_if { |f| File.directory?( "#{f}") == true }   # remove any directories
  return files
end

def standard_fileset( )
  fileset = []
  fileset.push("test/good-testdata/MD_AmerCh1b.xml")
  fileset.push("test/good-testdata/MD_Brit_v1CH1a.xml")
  return fileset

end

def wikipediaQueryRevisions( lang, params )
  return JSON.parse(RestClient.get("http://#{lang}.wikipedia.org/w/api.php", :params => {
    :format => "json",
    :action => "query"
  }.merge(params))).fetch("query", {}).fetch("pages", {}).values.map { |page| page.fetch("revisions", []) }.flatten
end

def wikipedia( title, limit=5, lang="en" )
  revision_ids = wikipediaQueryRevisions(lang, {
    :titles => title,
    :prop => "revisions",
    :rvlimit => 500,
    :rvprop => "ids|flags"    
  }).select { |rev|  !rev.has_key?("minor")  }.map { |rev| rev["revid"] }.slice(0, limit)

  wikipediaQueryRevisions(lang, {
    :revids => revision_ids.join("|"),
    :prop => "revisions",
    :rvprop => "content"    
  }).map { |rev| rev.fetch("*", "") }.select { |rev| rev != "" }
end