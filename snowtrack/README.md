Simple snowtrack shader demo.

The idea is from Batman: Arkham Origins, [YouTube presentaton on GDC 14](https://www.youtube.com/watch?v=87rg95XBalE).

The same idea was applied also for example in Horizon Zero Dawn: The Frozen Wilds, see [GPU Zen 2, Chapter 2.2](https://www.amazon.com/GPU-Zen-Advanced-Rendering-Techniques/dp/179758314X).

This demo is not nearly as advanced but uses the same basic idea: render the objects (write only z) with an orthographic camera from below and use that as height for offsetting tesselated vertex positions.

![snowtrack](snowtrack.png?raw=true "snowtrack")
