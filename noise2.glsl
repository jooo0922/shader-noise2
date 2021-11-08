#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main() {
  vec2 coord = gl_FragCoord.xy / u_resolution;
  coord.x *= u_resolution.x / u_resolution.y;

  vec3 col;

  gl_FragColor = vec4(col, 1.);
}

/*
  vec2 인자를 받아서 float 값을 리턴하는 노이즈 함수 만들기 (feat. 2D Noise 만들기)


  일단 기본적인 컨셉은 아래와 같음.

  캔버스를 격자로 나눈다고 가정하면,
  격자의 한 칸에서 끝부분에 위치하는 각 꼭지점들의 좌표값((0, 0), (0, 1), (1, 0), (1, 1))들도 있게 됨.

  이때, 해당 칸 영역에 존재하는 픽셀들에 대해서 각각 노이즈값을 리턴받으려면,
  해당 칸 영역내의 각 픽셀과 끝부분에 위치하는 각 꼭지점 사이의 거리에 대해
  shader-random1 예제에서 배웠던 vec2 / float 랜덤함수를 이용하여 
  랜덤값들을 리턴받고, 그 랜덤값들을 적절하게 mix 해주면,
  해당 칸 영역 내에서의 노이즈값을 계산할 수 있음.

  -> 이러한 방식이 2D 노이즈를 만드는 가장 기본적인 방법인 Value Noise 라고 함.
  자세한 그림과 내용은 thebookofshaders.com 에 잘 나와있음.
*/