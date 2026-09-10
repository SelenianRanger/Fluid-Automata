using Godot;

[GlobalClass]
public partial class GameSettingsResource : Resource
{
    [Export] 
    public Vector2I GridSize = new(200, 200);
    
    [Export] 
    public Vector2I SectionSize = new(20, 20);
    
    [Export] 
    public float UpdateSpeed = 10.0f;

    [Export] 
    public int UndoCount = 300;

    public Vector2I SectionGridSize => GridSize / SectionSize;
}
