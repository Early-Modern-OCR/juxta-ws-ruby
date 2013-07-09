require 'test/unit'
require 'config'
require 'juxta'

class TestTask < Test::Unit::TestCase

  def setup
     # create connection to the service
     @juxta = Juxta.new(JuxtaServicename, JuxtaUsername, JuxtaPassword)
  end

  def teardown
  end

  def wait_until_complete( task_id )
    while true do
      sleep(2.0)
      resp = @juxta.get_status( task_id )
      case resp
        when 'COMPLETE'
          return true

        when 'FAILED'
          return false
      end
    end

  end

  def test_bad_task_status
     begin
        status = @juxta.get_status( "bad-task-id" )
        assert( status == "UNAVAILABLE", "Incorrect status report")
     rescue Exception => e
        assert( false, "Unexpected exception (#{e})")
     end

  end

  def test_missing_task_status
     begin
        status = @juxta.get_status( "0000" )
        assert( status == "UNAVAILABLE", "Incorrect status report")
     rescue Exception => e
        assert( false, "Unexpected exception (#{e})")
     end
  end

  def test_good_task_status
     begin
        # create a standardized file set...
        file_set = standard_fileset( )

        # make the witness set...
        src_ids, wit_ids, set_id = @juxta.create_witness_set( file_set )
        assert( src_ids.length != 0, "Zero length source list" )
        assert( wit_ids.length != 0, "Zero length witness list" )
        assert( src_ids.length == wit_ids.length, "Differing size asset lists" )

        # collate...
        task_id = @juxta.async_collate_set( set_id )
        status = wait_until_complete( task_id )
        assert( status == true, "Collate status failed")

        # visualizations
        task_id = @juxta.async_get_as_html( "set/#{set_id}/view?mode=heatmap" )
        status = wait_until_complete( task_id )
        assert( status == true, "Get html status failed")

        # cleanup the witness set
        @juxta.delete_set( set_id )
        @juxta.destroy_witness_set( src_ids, wit_ids )
     rescue Exception => e
        assert( false, "Unexpected exception (#{e})")
     end
  end

end
