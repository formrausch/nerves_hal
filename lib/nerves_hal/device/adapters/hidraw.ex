
  defmodule Nerves.HAL.Device.Adapters.Hidraw do
    use Nerves.HAL.Device.Adapter, subsystem: "hidraw"

    require Logger

    def attributes(device) do
      device_file = Nerves.HAL.Device.device_file(device)

      info =
        Hidraw.enumerate()
        |> Enum.find(fn {dev_file, _} -> dev_file == device_file end)

      case info do
        {_, name} -> %{name: name}
        nil -> %{}
      end
    end

    def handle_connect(device, s) do
      case Nerves.HAL.Device.device_file(device) do
        nil ->
          {:error, "no dev file found", s}

        devfile ->
          {:ok, pid} = Hidraw.start_link(devfile)
          {:ok, Map.put(s, :driver, pid)}
      end
    end

    def handle_info({:hidraw, _dev, message}, s) do
      {:data_in, message, s}
    end
  end

