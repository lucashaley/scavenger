# Big Crate dressing configuration
{
  name: "cratebig",
  layers: [
    { name: "shadow", blendmode_enum: HuskGame::Constants::BLENDMODE[:multiply], z: -1 },
    { name: "main", blendmode_enum: :alpha, z: 0 }
  ],
  scales: {
    large: { w: 128, h: 128 },
    medium: { w: 128, h: 128 },
    small: { w: 128, h: 128 },
    tiny: { w: 128, h: 128 }
  }
}
