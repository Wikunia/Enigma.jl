# Enigma.jl

With this package you're able to encode/decode Enigma messages. It currently supports
- five different rotors of which three are used
- three different reflectors
- a plugboard

Not supported
- Difference between ring setting and rotor position. Currently it's only rotor position

## Installation

It's currently not an official Julia package but I intend to make it one. Therefore you currently need to
install it via the url.

```
] add https://github.com/Wikunia/Enigma.jl
```

Or if you want to hack a bit probably develop it

```
] dev https://github.com/Wikunia/Enigma.jl
```

**Info:** `]` is used in the Julia REPL to get into package mode.

This documentation is done in several parts.

- If you want to get a quick overview and just have a look at examples check out the [tutorial](tutorial.md).
- You just have some `How to` questions? -> [How to guide](how_to.md)
- You want to understand how it works deep down? Maybe improve it ;) -
  -  [Explanation](explanation.md)
  -  Check out my blog post about it [Enigma and Bombe](https://opensourc.es/blog/enigma-and-bombe)
  -  Have a look at my video [Enigma: Endless possibilities is not enough](https://youtu.be/4cf7dc_8u44)
- Gimme the code documentation directly! The [reference](reference.md) section got you covered.
- You've seen the visualization I used in one of my videos?
  - [How to use the visualization](p5js.md)

If you have some questions please feel free to ask me by making an [issue](https://github.com/Wikunia/Enigma.jl/issues).

You might be interested in the process of how I coded this: Checkout the full process on my blog [opensourc.es](https://opensourc.es/blog/enigma-and-bombe)