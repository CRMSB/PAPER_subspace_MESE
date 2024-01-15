```@meta
CurrentModule = Subspace_MESE
```

# Subspace_MESE

Documentation for the [Subspace_MESE](https://github.com/aTrotier/Subspace_MESE.jl) package, which implement the necessary functions to convert and reconstruct an accelerated 3D Multi-Echo Spin-Echo sequence with a subspace reconstruction in order to generate **T2** maps.


## Bruker Acquisition

This package is compatible with the sequence : **a\_MESE\_CS** which is available as a binary file in the folder : `MRI/PV6.0.1/`

The sequence is only available for the version PV6.0.1, implementation under PV360.6.5 is in progress.
The protocol used for an acceleration factor of CS=6/8/10 is also available at the same adress.

## Reconstruction Pipeline

The reconstruction pipeline has 4 steps :
- Convertion of the Bruker rawdataset to a MRIReco compatible format (`/src/bruker_sequence.jl`)
- Generation of a temporal basis (`/src/build_basis.jl`)
- Reconstruction which is presented either as a script or a standard implementation
- T2 fitting (`/src/fit_T2_MESE.jl`)

![Reconstruction Pipeline](./img/fig_explain.png)

Those steps are described in their dedicated section.

A complete script is available at this link.