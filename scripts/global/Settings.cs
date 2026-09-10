using Godot;

public partial class Settings : Node
{
    public static Settings Instance { get; private set; }
    
    public GameSettingsResource Game = GD.Load<GameSettingsResource>("res://settings/default.tres");

    public override void _Ready()
    {
        Instance = this;
    }
}
