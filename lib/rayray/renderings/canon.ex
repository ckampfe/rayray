defmodule Rayray.Renderings.Canon do
  alias Rayray.Tuple

  def tick(env, projectile) do
    position = Tuple.add(projectile[:position], projectile[:velocity])

    velocity =
      projectile[:velocity]
      |> Tuple.add(env[:gravity])
      |> Tuple.add(env[:wind])

    %{position: position, velocity: velocity}
  end
end
