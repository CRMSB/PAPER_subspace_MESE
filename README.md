# Subspace_MESE.jl


| **Documentation**         | **Paper**                   |
|:------------------------- |:--------------------------- |
| [![][docs-img]][docs-url] | [![][paper-img]][paper-url] |



Subspace_MESE.jl is a Julia package that implements the subspace reconstruction for an accelerated MESE sequence for Bruker scanner (**PV6.0.1**). 
The reconstruction can be performed using MRIReco.jl (or BART for comparison purpose) with 3 subspaces generated with :
- a calibration area
- mono-exponential dictionary
- EPG dictionary

More information and examples are available in the article [![][paper-img]][paper-url] and in the  [![][docs-img]][docs-url]

![](./docs/src/img/fig_explain.png)

## How to give credit

If you use this package please acknowledge us by citing : https://doi.org/10.1002/mrm.30146

Additionally, if you use the sequence available in the MR sequence folder, please contact us to sign the sequence transfer agreement : aurelien.trotier@rmsb.u-bordeaux.fr

## Bruker sequence and protocol

The accelerated 3D MESE MR sequence and the corresponding protocol for fully-sampled / CS6 / CS8 and CS10 acquisitions, as used in the publication, are available in the folder `MR sequence/PV6.0.1` for **Bruker Paravision PV6.0.1**. Source code is available in this private directory.  Source code is available in this private directory : https://github.com/CRMSB/SEQ_BRUKER_a_MSME_CS/tree/v0.1.1b

The sequence was also implemented for **Bruker Paravision PV-360.3.5** and is available in the folder  `MR sequence/PV-360.3.5`. Source code is available in this private directory : https://github.com/CRMSB/SEQ_BRUKER_a_MESE_CS_360

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

You can install the package in any project with the following command :

- launch julia with the command `julia`
- enter the Julia package manager by typing `]` in the REPL. (the REPL should turn in blue)
- if you want to activate an environment, type : `activate .` (otherwise the package will be installed in the global environment)
- In order to add our unregistered package, type `add https://github.com/CRMSB/PAPER_subspace_MESE`
- if you want to use the package : `using Subspace_MESE`

## Reproducing figure 8
In order to reproduce figure 8, we will run a script from the `docs` project environment which add the dependency to the plotting package `CairoMakie`.
This folder contains the `Project.toml` and `Manifest.toml` that list all the dependencies and the version used to produce the figure. If you want to use newer 

### Steps
In order to run the example you need to :
- compile the BART toolbox : https://mrirecon.github.io/bart/ (you can skip this step if you don't want to plot the BART reconstruction). After compilation/installation you can check the library path with `which bart`
- download the dataset : https://zenodo.org/records/10610639 and extract the zip file.
- download the current repository : `git clone https://github.com/CRMSB/PAPER_subspace_MESE`
- Open a terminal and move to the `docs` folder in this repository and launch julia with this command in the terminal: `julia --project -t auto`
- edit the script in `docs/lit/example/subspace_julia_epg.jl` and put the correct path in the variable 
  - line 46 : `path_raw` should point to the bruker folder `10`
  - line 49 : `path_bart` should point to the compiled bart library 
- run the literate example using the Manifest.toml files that stores the version of all the packages used to generate the figure 
  ```julia
  using Pkg
  Pkg.instantiate()
  include("lit/examples/subspace_julia_epg.jl")
  ```

If you want to start from a fresh environment you need to add the correct version of this repository as well as the plotting library `CairoMakie.jl` (put the correct path to the script `subspace_julia_epg.jl` if you are not in the `docs` folder)

  ```julia
  using Pkg

  Pkg.add(url="https://github.com/CRMSB/PAPER_subspace_MESE",rev="1.0.1")
  Pkg.add(name="CairoMakie", version="0.11.3")
  Pkg.instantiate()
  include("lit/examples/subspace_julia_epg.jl")
  ```

The figure will be saved as `fig_bart_julia.png` in the `docs` folder.

### Note
If you obtain the error : 
```julia
LoadError: ArgumentError: Package CairoMakie not found in current path
```
You might not have launch the script from the right environment. You should first move to the `docs` folder before launching `julia --project -t auto` in order to use the Project.toml that includes `CairoMakie.jl` package.


## Version

- 1.1.0
  - add sequence a_MESE_CS_360 (v0.0.1) for paravision 360 


---

[docs-img]: https://img.shields.io/badge/docs-latest%20release-blue.svg
[docs-url]: https://crmsb.github.io/PAPER_subspace_MESE/dev/

[paper-img]: https://img.shields.io/badge/doi-10.1002/mrm.30146-blue.svg
[paper-url]: https://doi.org/10.1002/mrm.30146
