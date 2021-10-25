defmodule ScenicDriverFBTFT do
  use Scenic.ViewPort.Driver

  alias Scenic.ViewPort.Driver
  require Logger

  @default_refresh_rate 200
  @minimal_refresh_rate 100

  @impl true
  def init(viewport, size, config) do
    vp_supervisor = vp_supervisor(viewport)
    {:ok, _} = Driver.start_link({vp_supervisor, size, %{module: Scenic.Driver.Nerves.Rpi}})

    interval =
      cond do
        is_integer(config[:interval]) and config[:interval] > 100 -> config[:interval]
        is_integer(config[:interval]) -> @minimal_refresh_rate
        true -> @default_refresh_rate
      end

    {width, height} = size
    {:ok, cap} = RpiFbCapture.start_link(width: width, height: height, display: 0)

    Process.send_after(self(), :capture, 4_000)

    {:ok,
     %{
       viewport: viewport,
       size: size,
       cap: cap,
       last_crc: -1,
       interval: interval
     }}
  end

  @impl true
  def handle_info(:capture, state) do
    {:ok, frame} = RpiFbCapture.capture(state.cap, :rgb565)

    crc = :erlang.crc32(frame.data)

    if crc != state.last_crc do
      File.write("/dev/fb1", frame.data)
    end

    Process.send_after(self(), :capture, state.interval)
    {:noreply, %{state | last_crc: crc}}
  end

  defp vp_supervisor(viewport) do
    [supervisor_pid | _] =
      viewport
      |> Process.info()
      |> get_in([:dictionary, :"$ancestors"])

    supervisor_pid
  end
end
