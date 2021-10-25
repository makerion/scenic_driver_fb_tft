defmodule ScenicDriverInky.MixProject do
  use Mix.Project

  @pi_targets [:rpi, :rpi0, :rpi2, :rpi3, :rpi3a]

  def project do
    [
      app: :scenic_driver_fb_tft,
      version: "0.1.0",
      elixir: "~> 1.8",
      description: description(),
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:scenic, "~> 0.9"},
      {:scenic_driver_nerves_rpi, "~> 0.9", targets: @pi_targets},
      {:rpi_fb_capture, "~> 0.1", targets: @pi_targets},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    "Framebuffer TFT driver for Scenic"
  end

  defp package do
    %{
      name: "scenic_driver_fb_tft",
      description:
        "A library to provide a Scenic framework driver implementation for generic TFT devices over SPI.",
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/makerion/scenic_driver_fb_tft"}
    }
  end
end
