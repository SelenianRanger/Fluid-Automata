using Godot;
using System;
using System.Linq;

public partial class GameGrid : Node
{
	[Signal]
	public delegate void GridUpdatedEventHandler();
	
	[Signal]
	public delegate void OverlaysUpdatedEventHandler();
	
	public override void _Ready()
	{
		var timer = GetNode<Timer>("Timer");
		timer.Timeout += UpdateTick;
		timer.WaitTime = 1f / Settings.Instance.Game.UpdateSpeed;
		GameState.Instance.Init();
		UpdateTick();
		timer.Start();
	}

	public void ResetGrid()
	{
		GameState.Instance.ClearStateBuffer();
		UpdateTick();
	}
	
	public void ResetGrid(byte[] fill)
	{
		GameState.Instance.ClearStateBuffer();
		fill.AsSpan().CopyTo(GameState.Instance.Grid);
		Array.Fill(GameState.Instance.SectionGrid, 
			(byte)(GameState.SectionFlag.Draw | GameState.SectionFlag.Process));
		UpdateTick();
	}

	public void OnPaintStart()
	{
		if (GameState.Instance.IsBufferLoaded)
		{
			GameState.Instance.DiscardBuffer();
			GameState.Instance.SaveState();
		}
		PostDrawCleanup();
	}

	public void OnPaintEnd()
	{
		GameState.Instance.SaveState();
		BufferNextFrame();
	}
	
	public void SetTile(Vector2I pos, byte value)
	{
		var index = GridUtils.GetPackedIndex(Settings.Instance.Game.GridSize, pos);
		if (GameState.Instance.Grid[index] == value) return;
		GameState.Instance.Grid[index] = value;
		MarkSection(pos);
		EmitSignal(SignalName.OverlaysUpdated);
	}
	
	private void UpdateTile(Vector2I pos)
	{
		if (GameRules.Rules.Any(rule => rule(pos)))
			MarkSection(pos);
	}
	
	private void MarkSection(Vector2I pos, bool markDraw = true)
	{
		var subI = pos.X /  Settings.Instance.Game.SectionSize.Y;
		var subJ = pos.Y /  Settings.Instance.Game.SectionSize.Y;
		var index = GridUtils.GetPackedIndex(Settings.Instance.Game.SectionGridSize,
			new Vector2I(subI, subJ));
		
		GameState.Instance.SectionGrid[index] |= (byte)(GameState.SectionFlag.Draw | GameState.SectionFlag.Process);
		foreach (var neighbor in GameState.Instance.SectionNeighbors[pos.X][pos.Y])
		{
			index = GridUtils.GetPackedIndex(Settings.Instance.Game.SectionGridSize,  neighbor);
			GameState.Instance.SectionGrid[index] |= (byte)GameState.SectionFlag.Process;
		}
	}

	private void UpdateSectionNeighbors(int id)
	{
		var subI = id /  Settings.Instance.Game.SectionGridSize.Y;
		var subJ = id %  Settings.Instance.Game.SectionGridSize.Y;
		var index = GridUtils.GetPackedIndex(
			Settings.Instance.Game.SectionGridSize, 
			new Vector2I(subI, subJ));
		if ((GameState.Instance.SectionGrid[index] & (byte)GameState.SectionFlag.Process) == 0) return;
		var i1 = Math.Max(1, subI * Settings.Instance.Game.SectionSize.X);
		var i2 = Math.Min(Settings.Instance.Game.GridSize.X - 1, i1 + Settings.Instance.Game.SectionSize.X);
		var j1 = Math.Max(1, subJ * Settings.Instance.Game.SectionSize.Y);
		var j2 = Math.Min(Settings.Instance.Game.GridSize.Y - 1, j1 + Settings.Instance.Game.SectionSize.Y);
		
		for (var x = i1; x < i2; x++)
		for (var y = j1; y < j2; y++)
		{
			index = GridUtils.GetPackedIndex(Settings.Instance.Game.GridSize, 
				new Vector2I(x, y));
			GameState.Instance.Neighbors[index] = 0;
			for (var i = -1; i < 2; i++)
			for (var j = -1; j < 2; j++)
			{
				if (i == 0 && j == 0) continue;
				var index2 = GridUtils.GetPackedIndex(Settings.Instance.Game.GridSize, 
					new Vector2I(x + i, y + j));
				GameState.Instance.Neighbors[index] += GameState.Instance.Grid[index2];
			}
		}
	}

	private void UpdateSection(int id)
	{
		var subI = id /  Settings.Instance.Game.SectionGridSize.Y;
		var subJ = id %  Settings.Instance.Game.SectionGridSize.Y;
		var index = GridUtils.GetPackedIndex(Settings.Instance.Game.SectionGridSize, 
			new Vector2I(subI, subJ));
		if ((GameState.Instance.SectionGrid[index] & (byte)GameState.SectionFlag.Process) == 0) return;
		GameState.Instance.SectionGrid[index] = (byte)GameState.SectionFlag.Pass;
		var i1 = Math.Max(1, subI * Settings.Instance.Game.SectionSize.X);
		var i2 = Math.Min(Settings.Instance.Game.GridSize.X - 1, i1 + Settings.Instance.Game.SectionSize.X);
		var j1 = Math.Max(1, subJ * Settings.Instance.Game.SectionSize.Y);
		var j2 = Math.Min(Settings.Instance.Game.GridSize.Y - 1, j1 + Settings.Instance.Game.SectionSize.Y);
		
		for (var i = i1; i < i2; i++)
		for (var j = j1; j < j2; j++) UpdateTile(new Vector2I(i, j));
		if ((GameState.Instance.SectionGrid[index] & (byte)GameState.SectionFlag.Draw) != 0)
			GameState.Instance.IsBufferLoaded = true;
	}

	public void UpdateNeighbors()
	{
		var taskId = WorkerThreadPool.AddGroupTask(Callable.From<int>(UpdateSectionNeighbors), 
			Settings.Instance.Game.SectionGridSize.X * Settings.Instance.Game.SectionGridSize.Y);
		WorkerThreadPool.WaitForGroupTaskCompletion(taskId);
	}

	public void UpdateGrid()
	{
		var taskId = WorkerThreadPool.AddGroupTask(Callable.From<int>(UpdateSection), 
			Settings.Instance.Game.SectionGridSize.X * Settings.Instance.Game.SectionGridSize.Y);
		WorkerThreadPool.WaitForGroupTaskCompletion(taskId);
	}

	public void Undo()
	{
		GameState.Instance.Undo();
		UpdateTick();
	}
	
	public void BufferNextFrame()
	{
		UpdateNeighbors();
		UpdateGrid();
	}

	public void PostDrawCleanup()
	{
		for (var i = 0; i < GameState.Instance.SectionGrid.Length; i++)
			GameState.Instance.SectionGrid[i] &= (byte)~GameState.SectionFlag.Draw;
	}
	
	public void UpdateTick()
	{
		if (!GameState.Instance.IsBufferLoaded) return;
		EmitSignal(SignalName.OverlaysUpdated);
		EmitSignal(SignalName.GridUpdated);
		GameState.Instance.SaveState();
		GameState.Instance.IsBufferLoaded = false;
		PostDrawCleanup();
		BufferNextFrame();
	}
	
}
