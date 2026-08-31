using Godot;

[GlobalClass]
public partial class SettingsGame : Resource
{
    [Export] 
    public Vector2I GridSize = new(100, 100);
    
    [Export] 
    public Vector2I SectionSize = new(10, 10);
    
    [Export] 
    public float UpdateSpeed = 10.0f;

    public Vector2I SectionGridSize => GridSize / SectionSize;
}
