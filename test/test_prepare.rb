require 'test/unit'
require 'juxta'

class TestPrepare < Test::Unit::TestCase

  def setup
    # create connection to the service
    @juxta = Juxta.new("http://127.0.0.1:8182")
    @filelist = get_filelist( "test/good-testdata" )
  end

  def teardown
  end

  def test_bad_source_id
    begin
       @juxta.transform_source( "bad-source-id" )
    rescue RestClient::BadRequest
       # this is expected...
    else
       assert( false, "Unexpected exception")
    end
  end

  def test_missing_source_id
    begin
       @juxta.transform_source( "0000" )
    rescue RestClient::ResourceNotFound
       # this is expected...
    else
       assert( false, "Unexpected exception")
    end
  end

  def test_happy_day
    begin
        # select a file at random
        file = @filelist[Random.rand( 0...@filelist.length ) ]

        # upload the source...
        src_id = @juxta.upload_source( file )
        assert( src_id != nil, "Failed to upload source file" )

        wit_id = @juxta.transform_source( src_id )
        assert( wit_id != nil, "Failed to transform source file" )

        status = @juxta.delete_witness( wit_id )
        assert( status == true, "Failed to delete witness file" )

        status = @juxta.delete_source( src_id )
        assert( status == true, "Failed to delete source file" )

     rescue Exception => e
        assert( false, "Unexpected exception (#{e})")
     end
  end

end
