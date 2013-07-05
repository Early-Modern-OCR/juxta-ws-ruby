require 'test/unit'
require 'juxta'

class TestVisualize < Test::Unit::TestCase

  def setup
    # create connection to the service
    @juxta = Juxta.new("http://127.0.0.1:8182")

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
    begin
      # delete the witness set
      status = @juxta.delete_set( @set_id )
      assert( status == true, "Failed to delete witness set" )

      # destroy witness set
      status = @juxta.destroy_witness_set( @src_ids, @wit_ids )
      assert( status == true, "Failed to destroy witness set" )
    rescue Exception => e
      assert( false, "Unexpected exception (#{e})")
    end
  end

  def test_bad_set_id
    begin
       @juxta.get_as_html( "set/bad-set-id/view?mode=heatmap" )
    rescue RestClient::BadRequest
       # this is expected...
    else
       assert( false, "Unexpected exception")
    end
  end

  def test_missing_set_id
    begin
       @juxta.get_as_html( "set/0000/view?mode=heatmap" )
    rescue RestClient::ResourceNotFound
       # this is expected...
    else
       assert( false, "Unexpected exception")
    end
  end

  def test_bad_witness_id
    begin
       @juxta.get_as_json( "set/#{@set_id}/view?mode=heatmap?base=bad-witness-id" )
    rescue RestClient::BadRequest
       # this is expected...
    else
       assert( false, "Unexpected exception")
    end
  end

  def test_missing_witness_id
    begin
      @juxta.get_as_json( "set/#{@set_id}/view?mode=heatmap&base=0000" )
    rescue RestClient::ResourceNotFound
      # this is expected...
    else
      assert( false, "Unexpected exception")
    end
  end

  def test_bad_witness_set
    begin
       @juxta.get_as_html( "set/#{@set_id}/view?mode=sidebyside&docs=bad-witness-id,bad-witness-id" )
    rescue RestClient::BadRequest
       # this is expected...
    else
       assert( false, "Unexpected exception")
    end
  end

  def test_missing_witness_set
    begin
       @juxta.get_as_html( "set/#{@set_id}/view?mode=sidebyside&docs=0000,0000" )
    rescue RestClient::ResourceNotFound
       # this is expected...
    else
       assert( false, "Unexpected exception")
    end
  end

  def test_happy_day
    begin

        # get visualizations: heatmap
        html = @juxta.get_as_html( "set/#{@set_id}/view?mode=heatmap" )
        assert( ( html != nil && html.length != 0 ), "Failed to get heatmap visualization" )

        # get visualizations: sidebyside
        html = @juxta.get_as_html( "set/#{@set_id}/view?mode=sidebyside&docs=#{@wit_ids[0]},#{@wit_ids[1]}" )
        assert( ( html != nil && html.length != 0 ), "Failed to get side by side visualization" )

     rescue Exception => e
        assert( false, "Unexpected exception (#{e})")
     end
  end

end
