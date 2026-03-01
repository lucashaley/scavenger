# Ship sprite configuration
{
  name: "ship",
  layers: [
    { name: "main", blendmode_enum: :alpha, z: 0 },
    { name: "turret", blendmode_enum: :alpha, z: 1 },
    { name: "thrustnorth", blendmode_enum: :add, z: 2 },
    { name: "thrustsouth", blendmode_enum: :add, z: 3 },
    { name: "thrusteast", blendmode_enum: :add, z: 4 },
    { name: "thrustwest", blendmode_enum: :add, z: 5 },
    { name: "shadow", blendmode_enum: HuskGame::Constants::BLENDMODE[:multiply], z: -1 }
  ],
  scales: {
    large: { w: 64, h: 64 },
    medium: { w: 32, h: 32 },
    small: { w: 16, h: 16 }
  }
}
