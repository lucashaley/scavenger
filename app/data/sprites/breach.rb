# Breach terminal configuration
{
  name: "breach",
  layers: [
    { name: "base", blendmode_enum: :alpha, z: 0 },
    { name: "main", blendmode_enum: :alpha, z: 1 }
  ],
  scales: {
    large: { w: 128, h: 128 },
    medium: { w: 80, h: 80 },
    small: { w: 64, h: 64 },
    tiny: { w: 32, h: 32 }
  }
}
