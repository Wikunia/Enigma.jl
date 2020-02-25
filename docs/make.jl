using Documenter
using Enigma

makedocs(
    # See https://github.com/JuliaDocs/Documenter.jl/issues/868
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    strict = true,
    sitename = "Enigma",
    pages = [
        "Home" => "index.md",
        "Tutorial" => "tutorial.md",
        "How-To" => "how_to.md",
        "P5js visualization" => "p5js.md",
        "Explanation" => "explanation.md",
        "Reference" => "reference.md",
    ]
)

deploydocs(
    repo = "github.com/Wikunia/Enigma.jl.git",
)