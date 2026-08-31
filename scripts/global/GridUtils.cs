using Godot;

public partial class GridUtils : Node
{
    public static int GetPackedIndex(Vector2I size, Vector2I pos) =>
        pos.X * size.Y + pos.Y;

    public static Vector2I GetPackedCoords(Vector2I size, int index) => 
        new(index / size.Y, index % size.Y);
}
