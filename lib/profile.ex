defmodule Profiler do
  def profile_app do
    Ingestor.ingest(File.read!("example.txt"))
    WorkerServer.process()
    spawn(fn ->
      IO.puts("Starting :fprof profiling for the entire application...")

      # Start tracing all processes
      :fprof.start()
      :fprof.trace([:start, procs: :all])

      # Allow profiling to run for a while (e.g., 15 seconds)
      :timer.sleep(1_000)

      # Stop tracing
      :fprof.trace(:stop)

      # Generate a profile and analyze it
      IO.puts("Stopping :fprof and analyzing results...")
      :fprof.profile()
      :fprof.analyse()

      IO.puts("Profiling completed")
    end)
  end

end
