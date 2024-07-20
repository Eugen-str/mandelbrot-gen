# mandelbrot-gen

Generate an image of the Mandelbrot set through the command line

usage:

print help with `cabal run exes -- help`

to generate a default image use `cabal run`

to generate an image with your inputs use `cabal run exes -- [option] [value]...`

---


there are a few examples in `examples/EXAMPLES.md`, but here is a very basic one

```console
$ cabal run exes -- -x -0.5762 -y -0.4849 -w 1000 -zoom 0.02 -o example.png
```

executing that command outputs this file:

![generated mandelbrot set](examples/example.png)

