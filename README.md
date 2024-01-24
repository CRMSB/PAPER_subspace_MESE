# Subspace_MESE.jl


| **Documentation**         | **Paper**                   |
|:------------------------- |:--------------------------- |
| [![][docs-img]][docs-url] | [![][paper-img]][paper-url] |



Subspace_MESE.jl is a Julia package that implements the subspace reconstruction for an accelerated MESE sequence for Bruker scanner (**PV6.0.1**). 
The reconstruction can be performed using MRIReco.jl (or BART for comparison purpose) with 3 temporal basis :
- using the calibration area
- using an exponential dictionary
- using an EPG dictionary

## Julia Installation

To use the code, we recommend downloading Julia version 1.9.3 with `juliaup`.

<details>
<summary>Windows</summary>

#### 1. Install juliaup
```
winget install julia -s msstore
```
#### 2. Add Julia 1.9.3
```
juliaup add 1.9.3
```
#### 3. Make 1.9.3 default
```
juliaup default 1.9.3
```

<!---#### Alternative
Alternatively you can download [this installer](https://julialang-s3.julialang.org/bin/winnt/x64/1.7/julia-1.9.3-win64.exe).--->

</details>


<details>
<summary>Mac</summary>

#### 1. Install juliaup
```
curl -fsSL https://install.julialang.org | sh
```
You may need to run `source ~/.bashrc` or `source ~/.bash_profile` or `source ~/.zshrc` if `juliaup` is not found after installation.

Alternatively, if `brew` is available on the system you can install juliaup with
```
brew install juliaup
```
#### 2. Add Julia 1.9.3
```
juliaup add 1.9.3
```
#### 3. Make 1.9.3 default
```
juliaup default 1.9.3
```

<!---#### Alternative
Alternatively you can download [this installer](https://julialang-s3.julialang.org/bin/mac/x64/1.7/julia-1.9.3-mac64.dmg)--->

</details>

<details>
<summary>Linux</summary>

#### 1. Install juliaup

```
curl -fsSL https://install.julialang.org | sh
```
You may need to run `source ~/.bashrc` or `source ~/.bash_profile` or `source ~/.zshrc` if `juliaup` is not found after installation.

Alternatively, use the AUR if you are on Arch Linux or `zypper` if you are on openSUSE Tumbleweed.
#### 2. Add Julia 1.9.3
```
juliaup add 1.9.3
```
#### 3. Make 1.9.3 default
```
juliaup default 1.9.3
```
</details>

## MESE Package Installation

- Download the current repository : `git clone https://github.com/aTrotier/PAPER_subspace_MESE`
- move your terminal to the repository and launch julia `julia -t auto --project`
- enter the Julia package manager by typing `]` in the REPL and then calling the command:
`dev .`
- if you want to use the package you can now type in any julia session : `using Subspace_MESE`

## Reproducing the figure
In order to reproduce the last figure, you need to :
- compile the BART toolbox (you can skip this step if you don't want to plot the BART reconstruction)
- download the dataset : https://zenodo.org/records/10514187?preview=1
- download the current repository and move your terminal in the docs folder
- edit the script in `docs/lit/example/subspace_julia_epg.jl` and put the correct path in the variable `path_raw` and `path_bart`
- launch julia `julia --project -t auto`
- run the literate example :
  ```julia
  using Pkg
  Pkg.instantiate()
  include("lit/example/subspace_julia_epg.jl")
  ```
The figure will be saved in the `docs` folder



[docs-img]: https://img.shields.io/badge/docs-latest%20release-blue.svg
[docs-url]: https://atrotier.github.io/Subspace_MESE.jl

[paper-img]: https://img.shields.io/badge/doi-10.1002/mrm.29945-blue.svg
[paper-url]: https://doi.org/10.1002/mrm.???
