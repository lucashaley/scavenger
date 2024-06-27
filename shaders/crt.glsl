uniform sampler2D tex1;

varying vec2 v_texCoord;

float warp = 0.75; // simulate curvature of CRT monitor
float scan = 0.75; // simulate darkness between scanlines

// void mainImage(out vec4 fragColor,in vec2 fragCoord)
// 	{
// 		vec2 iResolution = vec2(1280.0, 720.0);
//
//     // squared distance from center
//     vec2 uv = fragCoord/iResolution.xy;
//     vec2 dc = abs(0.5-uv);
//     dc *= dc;
//
//     // warp the fragment coordinates
//     uv.x -= 0.5; uv.x *= 1.0+(dc.y*(0.3*warp)); uv.x += 0.5;
//     uv.y -= 0.5; uv.y *= 1.0+(dc.x*(0.4*warp)); uv.y += 0.5;
//
//     // sample inside boundaries, otherwise set to black
//     if (uv.y > 1.0 || uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0)
//         fragColor = vec4(0.0,0.0,0.0,1.0);
//     else
//     	{
//         // determine if we are drawing in a scanline
//         float apply = abs(sin(fragCoord.y)*0.5*scan);
//         // sample the texture
//     	fragColor = vec4(mix(texture(iChannel0,uv).rgb,vec3(0.0),apply),1.0);
//         }
// 	}

	void scanlines() {
	  vec4 frag = texture2D(tex1, v_texCoord);
	  vec2 uv = v_texCoord;
	  float centerOffset = -0.5;
	  vec2 uvCentered = uv + centerOffset;
	  // vec2 uvNew = uvCentered * (1.0 + 0.5 * vec2(4.0 / 3.0, 1.0) * length(uvCentered)) - centerOffset;
		// Pretty sure this is curvature
		vec2 uvNew = uvCentered * (1.0 + 0.1 * vec2(4.0 / 3.0, 1.0) * length(uvCentered)) - centerOffset;
	  float scanlineCount = 360.0;

	  // vec2 iResolution = vec2(1280.0, 720.0);
		vec2 iResolution = vec2(640.0, 640.0);
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

	  vec4 overlay = texture2D(tex1, v_texCoord);
	  if (overlay.r == 0.0 && overlay.g == 0.0 && overlay.b == 0.0) {
	    gl_FragColor.r = 1.0;
	    gl_FragColor.g = 1.0;
	    gl_FragColor.b = 1.0;
	    gl_FragColor.a = 1.0;
	  }
	}

  void main() {
		// gl_FragColor = texture2D(tex1, v_texCoord);
    // mainImage(gl_FragColor);
    scanlines();
    // noop();
  }
