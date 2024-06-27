uniform sampler2D tex0;
uniform sampler2D tex1;

uniform float mouse_coord_x;
uniform float mouse_coord_y;
uniform int tick_count;

varying vec2 v_texCoord;

void noop() {
  gl_FragColor = texture2D(tex0, v_texCoord);
}

void scanlines() {
  vec4 frag = texture2D(tex0, v_texCoord);
  vec2 uv = v_texCoord;
  float centerOffset = -0.5;
  vec2 uvCentered = uv + centerOffset;
  vec2 uvNew = uvCentered * (1.0 + 0.5 * vec2(4.0 / 3.0, 1.0) * length(uvCentered)) - centerOffset;
  float scanlineCount = 360.0;

  vec2 iResolution = vec2(1280.0, 720.0);
  float brightness = floor((uvNew.y * iResolution.y) / (iResolution.y / scanlineCount));
  brightness = brightness - 2.0 * floor(brightness / 2.0);
  brightness = brightness == 0.0 ? 1.0 : 0.5;
  if (uvNew.x >= 0.0 && uvNew.x <= 1.0 && uvNew.y >= 0.0 && uvNew.y <= 1.0) {
    gl_FragColor = texture2D(tex0, uvNew);
    gl_FragColor = vec4(gl_FragColor.rgb * brightness, 1.0);
  } else {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
  }
  gl_FragColor.a = 1.0;

  vec4 overlay = texture2D(tex0, v_texCoord);
  if (overlay.r == 0.0 && overlay.g == 0.0 && overlay.b == 0.0) {
    gl_FragColor.r = 1.0;
    gl_FragColor.g = 1.0;
    gl_FragColor.b = 1.0;
    gl_FragColor.a = 1.0;
  }
}

void water() {
  vec4 displacement = texture2D(tex1, v_texCoord);
  vec2 distortedCoords = vec2(v_texCoord.x + (displacement.r * 0.02), v_texCoord.y + (displacement.r * 0.02));
  vec2 mouse_coords = vec2(mouse_coord_x, mouse_coord_y);
  float radius_prec = (mod(float(tick_count) / 5.0, 100.0) / 100.0);
  float radius_perc_sin = sin(radius_prec * 3.14159);
  float radius = 0.25 * radius_perc_sin + 0.1;
  float distance_x = abs(mouse_coords.x - v_texCoord.x);
  float distance_y = abs(mouse_coords.y - v_texCoord.y);
  distance_x = distance_x * 16.0 / 9.0;
  float hypotenuse = sqrt(distance_x * distance_x + distance_y * distance_y);
  if (abs(hypotenuse - radius) < 0.001) {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
  } else if (distance_x < radius && distance_y < radius && hypotenuse < radius) {
    gl_FragColor = texture2D(tex0, v_texCoord);
  } else {
    gl_FragColor = texture2D(tex0, distortedCoords);
  }
}

void main() {
  water();
  // scanlines();
  // noop();
}
