require 'test/unit'
require 'config'
require 'juxta'

class TestCollate < Test::Unit::TestCase

  def setup
     # create connection to the service
     @juxta = Juxta.new(JuxtaServicename, JuxtaUsername, JuxtaPassword)

     # create a standardized file set...
     @file_set = standard_fileset( )
  end

  def teardown
  end

  def test_bad_set_id
     begin
        @juxta.collate_set( "bad-set-id" )
     rescue RestClient::BadRequest
        # this is expected...
     else
        assert( false, "Unexpected exception")
     end
  end

  def test_missing_set_id
     begin
        @juxta.collate_set( "0000" )
     rescue RestClient::ResourceNotFound
        # this is expected...
     else
        assert( false, "Unexpected exception")
     end
  end

  def test_happy_day
     begin
        # make the witness set...
        src_ids, wit_ids, set_id = @juxta.create_witness_set( @file_set )
        assert( src_ids.length != 0, "Zero length source list" )
        assert( wit_ids.length != 0, "Zero length witness list" )
        assert( src_ids.length == wit_ids.length, "Differing size asset lists" )

        # tokenize...
        status = @juxta.tokenize_set( set_id )
        assert( status == true, "Failed to tokenize witness set" )

        # collate...
        status = @juxta.collate_set( set_id )
        assert( status == true, "Failed to collate witness set" )

        # delete the witness set
        status = @juxta.delete_set( set_id )
        assert( status == true, "Failed to delete witness set" )

        # destroy witness set
        status = @juxta.destroy_witness_set( src_ids, wit_ids )
        assert( status == true, "Failed to destroy witness set" )
     rescue Exception => e
        assert( false, "Unexpected exception (#{e})")
     end
  end

end
