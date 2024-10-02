uniform sampler2D tex0;
uniform sampler2D tex1;
uniform sampler2D tex2;

varying vec2 v_texCoord;

void scanlines() {
	// Distortion
	vec4 frag = texture2D(tex1, v_texCoord);
	vec2 uv = v_texCoord;
	float viewport_mask = texture2D(tex2, v_texCoord).r;
	float centerOffset = -0.25;
	float scaleFactor = 0.9;
	float curvature = 0.15;
	vec2 newOffset = vec2(-0.5, -0.25);
	vec2 uvCentered = (uv * scaleFactor) + (newOffset * scaleFactor);
	vec2 uvNew = uvCentered * (1.0 + curvature * vec2(4.0 / 3.0, 1.0) * length(uvCentered)) - newOffset;

	// Scanlines
	float scanlineCount = 720.0;
	vec2 iResolution = vec2(1280.0, 720.0);
	float brightness = floor((uvNew.y * iResolution.y) / (iResolution.y / scanlineCount));
	brightness = brightness - 2.0 * floor(brightness / 2.0);
	brightness = brightness == 0.0 ? 1.0 : 0.5;
	if (uvNew.x >= 0.0 && uvNew.x <= 1.0 && uvNew.y >= 0.0 && uvNew.y <= 1.0) {
		gl_FragColor = texture2D(tex1, uvNew);
		gl_FragColor = vec4(gl_FragColor.rgb * brightness, 1.0);
	} else {
		gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
	}
	gl_FragColor.a = 1.0;

	if (viewport_mask < 0.5) {
		gl_FragColor = texture2D(tex0, v_texCoord);
	}
}

void main() {
	scanlines();
}
