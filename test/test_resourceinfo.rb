require 'test/unit'
require 'config'
require 'juxta'

class TestResourceInfo < Test::Unit::TestCase

  def setup
      # create connection to the service
      @juxta = Juxta.new(JuxtaServicename, JuxtaUsername, JuxtaPassword)

      # create a standardized file set...
      @file_set = standard_fileset( )

      begin
         # make the witness set...
         @src_ids, @wit_ids, @set_id = @juxta.create_witness_set(  @file_set )
         assert( @src_ids.length != 0, "Zero length source list" )
         assert( @wit_ids.length != 0, "Zero length witness list" )
         assert( @src_ids.length == @wit_ids.length, "Differing size asset lists" )
      rescue Exception => e
         assert( false, "Unexpected exception (#{e})")
      end
  end

  def teardown
     begin
         # destroy witness set
         status = @juxta.destroy_witness_set(  @src_ids, @wit_ids )
         assert( status == true, "Failed to destroy witness set" )
         
         # delete the witness set
         status = @juxta.delete_set(  @set_id )
         assert( status == true, "Failed to delete witness set" )         
      rescue Exception => e
         assert( false, "Unexpected exception (#{e})")
      end
  end

  def test_missing_get_source_info
    begin
      source_id = 99999999
      @juxta.get_info(  "source/#{source_id}" )
    rescue RestClient::ResourceNotFound
      # this is expected...
    else
      assert( false, "Unexpected exception")
    end
  end


  def test_good_get_source_info
    begin
      # dont use a workspace as the info request does not want it ???
      sources = @juxta.list_sources()
      assert( sources.size != 0, "Empty source list" )
      src_id = sources[ 0 ][ 'id' ]
      resp = @juxta.get_info(  "source/#{src_id}" )
      assert( resp.length != 0, "Empty source info" )
   rescue Exception => e
      assert( false, "Unexpected exception (#{e})")
    end
  end
  
  
  def test_missing_get_set_info
    begin
      set_id = 99999999
      @juxta.get_info(  "set/#{set_id}" )
    rescue RestClient::ResourceNotFound
      # this is expected...
    else
      assert( false, "Unexpected exception")
    end
  end
  
  def test_good_get_set_info
    begin
      sets = @juxta.list_sets()
      assert( sets.size != 0, "Empty set list" )
      set_id = sets[ 0 ][ 'id' ]
      resp = @juxta.get_info( "set/#{set_id}" )
      assert( resp.length != 0, "Empty set info" )
    rescue Exception => e
      assert( false, "Unexpected exception (#{e})")
    end
  end
  
  def test_missing_get_witness_info
    begin
      wit_id = 99999999
      @juxta.get_info( "witness/#{wit_id}" )
    rescue RestClient::ResourceNotFound
      # this is expected...
    else
      assert( false, "Unexpected exception")
    end
  end
  
  def test_good_get_witness_info
    begin
      witnesses = @juxta.list_witnesses(   )
      assert( witnesses.size != 0, "Empty witness list" )
      wit_id = witnesses[ 0 ][ 'id' ]
      resp = @juxta.get_info(  "witness/#{wit_id}" )
      assert( resp.length != 0, "Empty witness info" )
    rescue Exception => e
      assert( false, "Unexpected exception (#{e})")
    end
  end

end
