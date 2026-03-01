# Mine sprite configuration
{
  name: "mine",
  layers: [
    {
      name: "main",
      animations: [
        {
          name: "idle",
          frames: 3,
          hold: 10,
          repeat: :forever
        }
      ],
      blendmode_enum: :alpha,
      z: 0
    },
    {
      name: "fx",
      blendmode_enum: :add,
      z: 2,
      animations: [
        {
          name: "blow",
          frames: 7,
          hold: 2,
          repeat: :once
        }
      ]
    },
    {
      name: "shadow",
      blendmode_enum: HuskGame::Constants::BLENDMODE[:multiply],
      z: -1
    }
  ],
  scales: {
    large: { w: 64, h: 64 },
    medium: { w: 40, h: 40 },
    small: { w: 32, h: 32 },
    tiny: { w: 16, h: 16 }
  }
}
