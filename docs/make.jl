try
    using Subspace_MESE
catch
    using Subspace_MESE
end
using Documenter, Literate

include("generate_lit.jl")

DocMeta.setdocmeta!(Subspace_MESE, :DocTestSetup, :(using Subspace_MESE); recursive=true)

makedocs(;
    modules=[Subspace_MESE],
    authors="aTrotier <a.trotier@gmail.com> and contributors",
    repo="https://github.com/CRMSB/PAPER_subspace_MESE/blob/{commit}{path}#{line}",
    sitename="Subspace_MESE.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://CRMSB.github.io/Subspace_MESE.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Installation" =>"installation.md",
        "Convert data" => "convert.md",
        "Subspace generation" => "building_basis.md",
        "Subspace Reconstruction" => "reconstruction_subspace.md",
        "T₂ mapping" => "fit_T2.md",
        "Examples" => pages("examples"),
        "API" => "api.md",
    ],
)

deploydocs(;
    repo="github.com/CRMSB/PAPER_subspace_MESE",
    devbranch="main",
)
