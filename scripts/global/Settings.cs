using Godot;

public partial class Settings : Node
{
    public static Settings Instance { get; private set; }
    
    public SettingsGame Game = GD.Load<SettingsGame>("res://settings/default.tres");

    public override void _Ready()
    {
        Instance = this;
    }
}
