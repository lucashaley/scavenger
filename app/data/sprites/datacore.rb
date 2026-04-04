# Data Core connector configuration
{
  name: "datacore",
  layers: [
    { name: "shadow", blendmode_enum: HuskGame::Constants::BLENDMODE[:multiply], z: -1 },
    { name: "main", blendmode_enum: :alpha, z: 0 },
    { name: "network", blendmode_enum: :add, z: 1 }
  ],
  scales: {
    large: { w: 128, h: 128 },
    medium: { w: 128, h: 128 },
    small: { w: 128, h: 128 },
    tiny: { w: 128, h: 128 }
  }
}
