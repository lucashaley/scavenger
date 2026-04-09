# Sweeper agent configuration
{
  name: "sweeper",
  layers: [
    {
      name: "base",
      animations: [
        {
          name: "idle",
          frames: 7,
          hold: 6,
          repeat: :forever
        }
      ],
      blendmode_enum: :alpha,
      z: 0,
      # scales: [:large]
    }
  ],
  scales: {
    large: { w: 64, h: 64 },
    medium: { w: 40, h: 40 },
    small: { w: 32, h: 32 },
    tiny: { w: 16, h: 16 }
  }
}
