varying vec2 v_texCoord; uniform sampler2D tex0;

void main() {
  gl_FragColor = texture2D(tex0, v_texCoord);
}
