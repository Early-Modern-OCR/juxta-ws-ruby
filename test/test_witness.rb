require 'test/unit'
require 'config'
require 'juxta'

class TestWitness < Test::Unit::TestCase

  def setup
    @juxta = Juxta.new(JuxtaServicename, JuxtaUsername, JuxtaPassword)
    filename = "test/good-testdata/dgr.ltr.0558.rad.xml"
    @src_id = @juxta.upload_source( filename )
    @wit_id = @juxta.transform_source( @src_id )
  end

  def teardown
    @juxta.delete_witness( @wit_id )
    @juxta.delete_source( @src_id )
  end

  def test_good_get_witness
    begin
      witnesses = @juxta.list_witnesses()
      assert( witnesses.size != 0, "Empty witness set" )
      data = @juxta.get_witness( witnesses[ 0 ][ 'id' ] )
      assert( data.length != 0, "Empty witness content")
    rescue Exception => e
      assert( false, "Unexpected exception (#{e})")
    end
  end

  def test_missing_get_witness
    begin
      @juxta.get_witness( 0 )
    rescue RestClient::ResourceNotFound
      # this is expected...
    else
      assert( false, "Unexpected exception")
    end
  end

  def test_good_rename_witness
    begin
      witnesses = @juxta.list_witnesses( )
      assert( witnesses.size != 0, "Empty witness set" )
      wit_id = witnesses[ 0 ][ 'id' ]
      new_name = make_guid( )
      new_id = @juxta.rename_witness( wit_id, new_name )
      assert( new_id.nil? == false, "Witness rename failed")
    rescue Exception => e
      assert( false, "Unexpected exception (#{e})")
    end
  end

  def test_missing_rename_witness
    begin
      wit_id = 99999999
      new_name = make_guid( )
      new_id = @juxta.rename_witness( wit_id, new_name )
    rescue RestClient::ResourceNotFound
      # this is expected...
    else
      assert( false, "Unexpected exception")
    end
  end

  def test_list_witness
    begin
      witnesses = @juxta.list_witnesses( )
      assert( witnesses.size != 0, "Empty witness set" )
    rescue Exception => e
      assert( false, "Unexpected exception (#{e})")
    end
  end

end
