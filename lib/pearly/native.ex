defmodule Pearly.Native do
  @moduledoc false

  use Rustler, otp_app: :pearly, crate: "pearly_nif"

  defmodule NifNotLoadedError do
    @moduledoc false

    defexception message: "nif not loaded"
  end

  def highlight(_format, _lang, _theme, _source), do: err()

  defp err() do
    throw NifNotLoadedError
  end
end
