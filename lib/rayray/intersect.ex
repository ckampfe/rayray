defprotocol Rayray.Intersect do
  @doc "Calculates the intersects of the ray on the object"
  def intersect(object, ray)
end
