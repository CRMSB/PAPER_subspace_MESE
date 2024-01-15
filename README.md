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
To install this package, enter the Julia package manager by typing `]` in the REPL and then calling the command:

`add https://github.com/atrotier/Subspace_MESE.jl`

## An example is available

For more details, please refer to the paper and the above linked documentation.


[docs-img]: https://img.shields.io/badge/docs-latest%20release-blue.svg
[docs-url]: https://atrotier.github.io/Subspace_MESE.jl

[paper-img]: https://img.shields.io/badge/doi-10.1002/mrm.29945-blue.svg
[paper-url]: https://doi.org/10.1002/mrm.???