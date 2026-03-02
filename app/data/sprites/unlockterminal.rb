# Unlock Terminal connector configuration
{
  name: "unlockterminal",
  layers: [
    { name: "shadow", blendmode_enum: HuskGame::Constants::BLENDMODE[:multiply], z: -1 },
    { name: "main", blendmode_enum: :alpha, z: 0 },
    { name: "lights", blendmode_enum: :add, z: 1 }
  ],
  scales: {
    large: { w: 64, h: 64 },
    medium: { w: 40, h: 40 },
    small: { w: 32, h: 32 }
  }
}
