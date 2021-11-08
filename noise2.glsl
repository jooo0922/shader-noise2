#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// vec2 / float 노이즈 함수를 이용해 2D Noise를 만들때는
// vec2 / float 랜덤함수가 필요함. (shader-random1 예제 설명 참고)
float random(vec2 v) {
  float f = dot(v, vec2(23.53, 32.124)); // vec2 데이터를 float 데이터로 바꿔주기 위해 임의의 vec2와 내적계산한 것. -> 내적의 결과값은 스칼라니까 float이 되겠지
  return fract(sin(f * 12.432) * 16234.12412);
}

// 이제 랜덤값을 가지고 2D Noise를 만드는 노이즈 함수를 만들거임.
float noise(vec2 v) {
  vec2 i = floor(v); // 전달된 픽셀 좌표값의 정수부분만 떼어낸 vec2
  vec2 f = fract(v); // 전달된 픽셀 좌표값의 소수부분만 떼어낸 vec2

  // 아래 필기에 정리한대로, 전달된 픽셀이 포함된 격자 한 칸의 4개의 꼭지점 좌표값을 구하는 것.
  vec2 v1 = i; // 좌하단 꼭지점 좌표값 (왜냐면, 해당 픽셀의 정수 부분만 떼어낸 좌표값은 격자 한 칸의 좌하단 시작점, 즉 원점과 다름없음!)
  vec2 v2 = i + vec2(1., 0.); // 우하단 꼭지점 좌표값 
  vec2 v3 = i + vec2(0., 1.); // 좌상단 꼭지점 좌표값 
  vec2 v4 = i + vec2(1., 1.); // 우상단 꼭지점 좌표값 

  // 4개의 꼭지점 좌표값을 vec2 / float 랜덤함수에 전달해서 랜덤값을 각각 리턴받음.
  float r1 = random(v1);
  float r2 = random(v2);
  float r3 = random(v3);
  float r4 = random(v4);

  /*
    이제 위에서 구한 각 꼭지점들의 랜덤값들을 섞는 방법이 중요함.

    1. 먼저, 좌하단 - 우하단끼리,
    좌상단 - 우상단끼리 현재 픽셀 좌표값의 실수부분만 떼어난 vec2인 f의 x좌표값 만큼의 비율로 mix 함

    2. 그 다음, mix한 각각의 결과값을 bot(bottom), top에 넣어준 뒤,
    bot과 top 값을 f의 y좌표값 만큼의 비율로 다시 mix 함

    -> 이렇게 함으로써, 
    현재 픽셀이 자신이 포함된 격자 한 칸의 4개의 꼭지점들로부터
    떨어진 4개의 거리값에 따른 영향력이 반영된 고유의 노이즈값을
    계산할 수 있게 되는 것!

    이 때, 단순히 f의 x, y 좌표값만 가지고 mix를 해버리면
    noise1에서 linear 하게, 선형적으로만 보간했던 예제와 다름없기 때문에
    격자의 칸 사이사이의 경계가 너무 날카롭게 잘보이게 됨.

    이거를 좀 뭉개주려면 곡선으로 보간을 해줘야 함.
    그러려면 smoothstep(0., 1., f)을 이용해서 f 값을 보간해줘야 함.
  */
  f = smoothstep(0., 1., f);
  float bot = mix(r1, r2, f.x);
  float top = mix(r3, r4, f.x);
  float ret = mix(bot, top, f.y);

  return ret;
}

void main() {
  vec2 coord = gl_FragCoord.xy / u_resolution; // 각 픽셀들 좌표값 normalize
  coord.x *= u_resolution.x / u_resolution.y; // 캔버스를 resizing 해도 왜곡이 없도록 좌표값에 해상도비율값 곰해줌.

  // 좌표계(격자)를 0 ~ 1 에서 0 ~ 10으로 Mapping해서 확대함.
  // 격자의 칸수가 좀 많아져야 각 격자별로 다양한 노이즈값을 리턴받을 수 있겠지?
  coord *= 10.;

  vec3 col = vec3(noise(coord));

  gl_FragColor = vec4(col, 1.);
}

/*
  vec2 인자를 받아서 float 값을 리턴하는 노이즈 함수 만들기 (feat. 2D Noise 만들기)


  일단 기본적인 컨셉은 아래와 같음.

  캔버스를 격자로 나눈다고 가정하면,
  격자의 한 칸에서 끝부분에 위치하는 각 꼭지점들의 좌표값
  (n, n), (n, n + 1), (n + 1, n), (n + 1, n + 1)들도 있게 됨.

  이때, 해당 칸 영역에 존재하는 픽셀들에 대해서 각각 노이즈값을 리턴받으려면,
  해당 칸 영역내의 각 픽셀과 끝부분에 위치하는 각 꼭지점의 좌표값을
  shader-random1 예제에서 배웠던 vec2 / float 랜덤함수에 전달해서 
  랜덤값들을 리턴받고, 그 랜덤값들을 적절하게 mix 해주면,
  해당 칸 영역 내에서의 노이즈값을 계산할 수 있음.

  -> 이러한 방식이 2D 노이즈를 만드는 가장 기본적인 방법인 Value Noise 라고 함.
  자세한 그림과 내용은 thebookofshaders.com 에 잘 나와있음.
  또는 2d-noise-concept.png 이미지 참고할 것.
*/

/*
  Value Noise의 한계


  Value Noise는 기본적으로
  격자의 각 칸마다 4개의 꼭지점 좌표값을 구한 뒤,
  각 꼭지점과 그 안에 포함된 픽셀들 사이의 거리에 따라
  노이즈값을 보간하여 계산하기 때문에

  4개의 꼭지점의 영향력이 고스란히 반영될 수밖에 없음.

  그러니까 아무리 smoothstep() 같은거로 곡선 보간을 해줘서
  경계를 부드럽게 뭉개줘도 기본적으로 blocky한 사각형들의 윤곽이 느껴질 수밖에 없음.


  반면, thebookofshaders.com 에서 
  Gradient Noise 예제 이미지를 보면 Value Noise보다
  훨씬 더 둥글둥글하고 경계선이 부드러워서 자연스러워 보이지?

  다음 shader-noise3 예제에서 공부할 것이
  이러한 Value Noise의 한계점을 해결하기 위한
  Gradient Noise와 Simplex Noise에 대해서 알아볼거임.


  Value Noise는 이렇게 모양도 안예쁘고 실제로 잘 사용할 일도 없을 것 같은데
  그럼 얘를 왜 배우나?

  기본적으로 Gradient, Simplex Noise들도 Value Noise와 기본 원리가 동일하기 때문.

  주변의 꼭지점을 구해서,
  그 꼭지점들과의 거리 또는 무언가를 첨가해서 
  비율을 보간시켜주는 방식은 유사하기 때문에
  이러한 근본 원리를 원초적으로 알 수 있는 이해에 도움이 되는 Noise 기법이기 때문에
  가장 먼저 훑고 지나가 본 것임.

  혹은 blocky한 노이즈를 사용해도 별 지장이 없는 경우
  굳이 다른 어려운 노이즈들을 사용하지 않고 
  기본 노이즈 기법을 사용해도 되니까
  배워둬서 나쁠 건 없음.
*/