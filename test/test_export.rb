require 'test/unit'
require 'config'
require 'juxta'

class TestExport < Test::Unit::TestCase
   def setup
      # create connection to the service
      @juxta = Juxta.new(JuxtaServicename, JuxtaUsername, JuxtaPassword)

      # create a standardized file set...
      @file_set = standard_fileset( )

      begin
      # make the witness set...
         @src_ids, @wit_ids, @set_id = @juxta.create_witness_set( @file_set )
         assert( @src_ids.length != 0, "Zero length source list" )
         assert( @wit_ids.length != 0, "Zero length witness list" )
         assert( @src_ids.length == @wit_ids.length, "Differing size asset lists" )

         # collate...
         status = @juxta.collate_set( @set_id )
         assert( status == true, "Failed to collate witness set" )
      rescue Exception => e
         assert( false, "Unexpected exception (#{e})")
      end
   end

   def teardown
   end

   def test_bad_set_id
      begin
         @juxta.export( "bad-set-id", "bad_wit" )
      rescue RestClient::BadRequest
      # this is expected...
      else
         assert( false, "Unexpected exception")
      end
   end

   def test_missing_set_id
      begin
         @juxta.export( "0000", "000" )
      rescue RestClient::ResourceNotFound
         # this is expected...
      else
         assert( false, "Unexpected exception")
      end
   end

   def test_happy_day
      begin

         resp = @juxta.export( @set_id, @wit_ids[0] )
         assert(resp.length > 0, "blank export response received")
         assert(!resp.index("<TEI").nil?, "missing TEI opener")
         assert(!resp.index("</TEI>").nil?, "missing TEI closer")
        
      rescue Exception => e
         assert( false, "Unexpected exception (#{e})")
      end
   end

end
