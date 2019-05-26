defprotocol Rayray.Normal do
  @doc "Calculates the normal on an object, at a given point"
  def normal_at(obj, point)
end
