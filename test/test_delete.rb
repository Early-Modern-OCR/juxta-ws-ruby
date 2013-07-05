require 'test/unit'
require 'juxta'

class TestDelete < Test::Unit::TestCase

  def setup
    # create connection to the service
    @juxta = Juxta.new("http://127.0.0.1:8182")
    @filename = "test/good-testdata/dgr.ltr.0558.rad.xml"
  end

  def teardown
  end

  def test_empty_file
    begin
       @juxta.upload_source(  "test/bad-testdata/empty.xml" )
    rescue RestClient::BadRequest
      # this is expected...
    else
      assert( false, "Unexpected exception")
    end
  end

  def test_bad_source_id
    begin
       @juxta.delete_source(  "bad-source-id" )
    rescue RestClient::BadRequest
       # this is expected...
    else
      assert( false, "Unexpected exception")
    end
  end

  def test_missing_source_id
    begin
       @juxta.delete_source(  "0000" )
    rescue RestClient::ResourceNotFound
       # this is expected...
    else
      assert( false, "Unexpected exception")
    end
  end

  def test_happy_day
    begin
       src_id = @juxta.upload_source(  @filename )
       assert(src_id.nil? == false, "Upload source id is nil" )

       status = @juxta.delete_source(  src_id )
       assert( status == true, "File delete failed")
    rescue Exception => e
      assert( false, "Unexpected exception (#{e})")
    end
  end

end
