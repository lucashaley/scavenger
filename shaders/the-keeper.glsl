uniform sampler2D tex0;
uniform sampler2D tex1; // water displacement
uniform sampler2D tex2; // water mask
uniform sampler2D tex3; // water
uniform sampler2D tex4; // fog_mask
uniform sampler2D tex5; // tree/sway
uniform int i_screen_h;

uniform float mouse_coord_y;
uniform int tick_count;
uniform float allscreen_w_px;
uniform float allscreen_h_px;
uniform float allscreen_offset_x_px;
uniform float allscreen_offset_y_px;

varying vec2 v_texCoord;

void noop() {
  gl_FragColor = texture2D(tex0, v_texCoord);
}

void water() {
  vec2 uv = v_texCoord;

  vec4 displacement = texture2D(tex1, uv);
  float displacment_magnitude = texture2D(tex2, uv).r;
  float displacement_threshold = 0.2;
  vec4 fog = texture2D(tex4, uv);

  if (displacment_magnitude <= displacement_threshold) {
    displacment_magnitude = 0.0;
  }

  vec2 distortedCoords = vec2(uv.x + ((1.0 - displacement.r) * 0.1),
                              uv.y + ((1.0 - displacement.r) * 0.1));

  if (displacment_magnitude <= displacement_threshold) {
    gl_FragColor = texture2D(tex0, v_texCoord);
  } else {
    gl_FragColor = texture2D(tex3, distortedCoords);

    if (1.0 - displacement.r > 0.9) {
      gl_FragColor.r = gl_FragColor.r + 0.2;
      gl_FragColor.g = gl_FragColor.g + 0.2;
      gl_FragColor.b = gl_FragColor.b + 0.5;
    }

    gl_FragColor.r += (1.0 - fog.r) * 0.1;
    gl_FragColor.g += (1.0 - fog.g) * 0.1;
    gl_FragColor.b += (1.0 - fog.b) * 0.1;
  }
}

void main() {
  water();
}
