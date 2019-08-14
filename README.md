# Scenic Driver FB TFT

A library to provide a Scenic framework driver implementation for SPI serial connected displays

This driver only runs on RPi devices as far as we know as it is based on the scenic rpi driver generating a framebuffer we can use.

Many thanks to the work on the Inky Scenic Driver folks (https://github.com/pappersverk/scenic_driver_inky) who worked through the framebuffer capturing from rpi, and Frank Hunleth for his tireless work (https://github.com/fhunleth/rpi_fb_capture) (as always)

## Installation

The package can be installed
by adding `scenic_driver_fb_tft` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:scenic_driver_fb_tft, "~> 1.0.0"}
  ]
end
```

## Usage

This library provides the `ScenicDriverFBTFT` driver module. Driver configuration:

```
config :sample_scenic_fb_tft, :viewport, %{
  name: :main_viewport,
  default_scene: {YourApp.Scene.Main, nil},
  size: {480, 320},
  opts: [scale: 1.0],
  drivers: [
    [
      module: Scenic.Driver.Local,
    ],
    %{
      module: ScenicDriverFBTFT
    }
  ]
}
```

Note: It is important to configure the ScenicLocalDriver because ScenicDriverFbTft reads from ScenicLocalDriver

For development on host, we recommend just using the glfw driver for scenic (also shown in the sample).
