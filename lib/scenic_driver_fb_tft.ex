defmodule ScenicDriverFBTFT do
  use Scenic.Driver

  alias Scenic.ViewPort.Driver
  require Logger

  @default_refresh_rate 200
  @minimal_refresh_rate 100

  @impl true
  def validate_opts(opts), do: {:ok, opts}

  @impl true
  def init(driver, config) do
    viewport = driver.viewport
    config = config[:opts]

    interval =
      cond do
        is_integer(config[:interval]) and config[:interval] > 100 -> config[:interval]
        is_integer(config[:interval]) -> @minimal_refresh_rate
        true -> @default_refresh_rate
      end

    {width, height} = viewport.size
    {:ok, cap} = RpiFbCapture.start_link(width: width, height: height, display: 0)

    Process.send_after(self(), :capture, 4_000)

    state = %{
      viewport: viewport,
      size: viewport.size,
      cap: cap,
      last_crc: -1,
      interval: interval
    }

    driver = assign(driver, :state, state)

    {:ok, driver}
  end

  @impl true
  def handle_info(:capture, driver) do
    state = driver.assigns.state
    {:ok, frame} = RpiFbCapture.capture(state.cap, :rgb565)

    crc = :erlang.crc32(frame.data)

    if crc != state.last_crc do
      File.write("/dev/fb1", frame.data)
    end

    Process.send_after(self(), :capture, state.interval)
    state = %{state | last_crc: crc}
    driver = assign(driver, :state, state)
    {:noreply, driver}
  end
end
