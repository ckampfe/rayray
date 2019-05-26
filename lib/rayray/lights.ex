defmodule Rayray.Lights do
  alias Rayray.Tuple

  defstruct position: nil, intensity: nil

  def point_light(position, intensity) do
    %__MODULE__{position: position, intensity: intensity}
  end

  def lighting(material, light, point, eyev, normalv) do
    effective_color = Tuple.multiply(material.color, light.intensity)
    lightv = Tuple.normalize(Tuple.subtract(light.position, point))
    ambient = Tuple.multiply(effective_color, material.ambient)
    light_dot_normal = Tuple.dot(lightv, normalv)
    black = Tuple.color(0, 0, 0)

    {diffuse, specular} =
      if light_dot_normal < 0 do
        {black, black}
      else
        diffuse =
          effective_color |> Tuple.multiply(material.diffuse) |> Tuple.multiply(light_dot_normal)

        reflectv = Tuple.reflect(Tuple.multiply(lightv, -1), normalv)
        reflect_dot_eye = Tuple.dot(reflectv, eyev)

        if reflect_dot_eye <= 0 do
          {diffuse, black}
        else
          factor = :math.pow(reflect_dot_eye, material.shininess)

          specular =
            light.intensity
            |> Tuple.multiply(material.specular)
            |> Tuple.multiply(factor)

          {diffuse, specular}
        end
      end

    # ambient + diffuse + specular
    ambient
    |> Tuple.add(diffuse)
    |> Tuple.add(specular)
  end
end
