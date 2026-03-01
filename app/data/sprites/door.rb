# Door sprite configuration
{
  name: "door",
  layers: [
    {
      name: "main",
      blendmode_enum: :alpha,
      z: 3
    },
    {
      name: "doors",
      animations: [
        { name: "open", frames: 4, hold: 4, repeat: :once },
        { name: "close", frames: 4, hold: 4, repeat: :once }
      ],
      blendmode_enum: :alpha,
      z: 2
    },
    {
      name: "lights",
      animations: [
        { name: "idle", frames: 7, hold: 4, repeat: :forever }
      ],
      blendmode_enum: :add,
      z: 4
    }
  ],
  scales: {
    large: { w: 64, h: 64 },
    medium: { w: 40, h: 40 },
    small: { w: 32, h: 32 },
    tiny: { w: 16, h: 16 }
  }
}
