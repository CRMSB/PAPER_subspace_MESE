# Unregistered package Installation

You can install the package in any project with the following command :

- launch julia with the command `julia`
- enter the Julia package manager by typing `]` in the REPL. (the REPL should turn in blue)
- if you want to activate an environment, type : `activate .` (otherwise the package will be installed in the global environment)
- In order to add our unregistered package, type `add https://github.com/aTrotier/PAPER_subspace_MESE`
- if you want to use the package : `using Subspace_MESE`


## Reproducing figure 8

In order to reproduce figure 8, you need to :
- compile the BART toolbox : https://mrirecon.github.io/bart/ (you can skip this step if you don't want to plot the BART reconstruction). After compilation/installation you can check the library path with `which bart`
- download the dataset : https://zenodo.org/records/10610639 and extract the zip file.
- download the current repository : `git clone https://github.com/aTrotier/PAPER_subspace_MESE`
- Open a terminal and move to the docs folder in this repository
- edit the script in `docs/lit/example/subspace_julia_epg.jl` and put the correct path in the variable 
  - line 27 : `path_raw` should point to the bruker folder `10`
  - line 30 : `path_bart` should point to the compiled bart library
- launch julia in the docs folder with this command in the terminal: `julia --project -t auto`
- run the literate example :
  ```julia
  using Pkg
  Pkg.add(url="https://github.com/aTrotier/PAPER_subspace_MESE")
  Pkg.instantiate()
  include("lit/examples/subspace_julia_epg.jl")
  ```
The figure will be saved as `fig_bart_julia.png` in the `docs` folder.