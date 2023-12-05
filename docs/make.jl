using Subspace_MESE
using Documenter

DocMeta.setdocmeta!(Subspace_MESE, :DocTestSetup, :(using Subspace_MESE); recursive=true)

makedocs(;
    modules=[Subspace_MESE],
    authors="aTrotier <a.trotier@gmail.com> and contributors",
    repo="https://github.com/aTrotier/Subspace_MESE.jl/blob/{commit}{path}#{line}",
    sitename="Subspace_MESE.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://aTrotier.github.io/Subspace_MESE.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/aTrotier/Subspace_MESE.jl",
    devbranch="main",
)
