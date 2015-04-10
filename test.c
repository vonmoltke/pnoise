#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#define M_PI 3.1415926535f

#define CUBE_DIM  (1024)
#define NUM_ITERS  (100)
#define RAND_SCALE (1.0f / RAND_MAX * M_PI * 2.0f);

typedef struct
{
  float x, y;
} Vec2;

static inline float lerp(const float a, const float b, const float v)
{
  return a * (1 - v) + b * v;
}

static inline float smooth(const float v)
{
  return v * v * (3 - 2 * v);
}

static inline Vec2 random_gradient()
{
  const float v = (float) rand() * RAND_SCALE;
  return (Vec2) { cosf (v), sinf (v) };
}

static inline float gradient(const Vec2 orig, const Vec2 grad, const Vec2 p)
{
  return grad.x * (p.x - orig.x) + grad.y * (p.y - orig.y);
}

typedef struct
{
  Vec2 rgradients[CUBE_DIM];
  int permutations[CUBE_DIM];
} Noise2DContext;

static inline Vec2 get_gradient(Noise2DContext* const ctx, const int x, const int y)
{
  const int idx = ctx->permutations[x] + ctx->permutations[y];
  return ctx->rgradients[idx & (CUBE_DIM - 1)];
}

static float noise2d_get(Noise2DContext* const ctx, const float x, const float y)
{
  Vec2 p = { x, y };
  
  // Cheap trick since inputs will always be [0, MAX_INT]
  const int x0 = (int)x;
  const int y0 = (int)y;
  const int x1 = x0 + 1;
  const int y1 = y0 + 1;
  const float x0f = (float)x0;
  const float y0f = (float)y0;

  const Vec2 grad0 = get_gradient(ctx, x0, y0);
  const Vec2 grad1 = get_gradient(ctx, x1, y0);
  const Vec2 grad2 = get_gradient(ctx, x0, y1);
  const Vec2 grad3 = get_gradient(ctx, x1, y1);

  const Vec2 origin0 = { x0f, y0f };
  const Vec2 origin1 = { x0f + 1.0f, y0f };
  const Vec2 origin2 = { x0f, y0f + 1.0f };
  const Vec2 origin3 = { x0f + 1.0f, y0f + 1.0f };
  
  float v0 = gradient(origin0, grad0, p);
  float v1 = gradient(origin1, grad1, p);
  float v2 = gradient(origin2, grad2, p);
  float v3 = gradient(origin3, grad3, p);

  float fx = smooth(x - origin0.x);
  float vx0 = lerp(v0, v1, fx);
  float vx1 = lerp(v2, v3, fx);
  float fy = smooth(y - origin0.y);
  return lerp (vx0, vx1, fy);
}

static void init_noise2d(Noise2DContext* const ctx)
{
  for (int i = 0; i < CUBE_DIM; i++)
  {
    ctx->rgradients[i] = random_gradient();
  }

  for (int i = 0; i < CUBE_DIM; i++)
  {
    const int j = rand() % (i + 1);
    ctx->permutations[i] = ctx->permutations[j];
    ctx->permutations[j] = i;
  }
}

int main(const int argc, const char **argv)
{
  srand(time (NULL));

  const char *symbols[] = { " ", "░", "▒", "▓", "█", "█" };
  float *pixels = malloc (sizeof (float) * CUBE_DIM * CUBE_DIM);

  Noise2DContext n2d;
  init_noise2d(&n2d);

  int pixel_index = 0;
  for (int i = 0; i < NUM_ITERS; ++i)
  {
    pixel_index = 0;

    for (int y = 0; y < CUBE_DIM; ++y)
    {
      for (int x = 0; x < CUBE_DIM; ++x)
      {
	const float v = noise2d_get(&n2d, x * 0.1f, y * 0.1f) * 0.5f + 0.5f;
	pixels[pixel_index] = v;
        ++pixel_index;
      }
    }
  }

  pixel_index = 0;
  for (int y = 0; y < CUBE_DIM; ++y)
  {
    for (int x = 0; x < CUBE_DIM; ++x)
    {
      const int idx = pixels[pixel_index] * 5.0f;
      printf ("%s", symbols[idx]);
      ++pixel_index;
    }
    printf ("\n");
  }

  return 0;
}
