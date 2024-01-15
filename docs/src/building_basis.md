# Building temporal basis

This package implement 3 differents temporal basis :
- Exponential basis
- Extended Phase Graph (EPG) basis
- Calibration basis

## How to build a basis

The 3 methods are based on the same concept :

Generate a dictionnary with the evolution of the signal at each echo time `signal_dict`

Apply with the Singular Value Decomposition on it
```julia
svd_obj = svd(signal_dict)
```

and then crop to the desired number of basis
```julia
basis = ComplexF32.(svd_obj.V)[:, 1:NUM_BASIS]
```

This concept can be applied to create your own basis for example directly from echo images.

## Difference between the 3 methods

Exponential and EPG basis build a dictionnary withthe signal evolution of the Multi-Echo Spin-Echo sequence for various $T_2$ (or $B_1$ for the EPG case).

The Calibration basis reconstructs low-resolution images at each Echo Time points with the calibration fully sampled area.

# Exponential basis
```@docs
MESE_basis_exp
```

In the publication, the basis is extracted from a dictionnary generated with a range of $T_2$ from 1 ms to 2000 ms with a step of 1 ms.

Other approachs can be used :
- a logarithmic repartition of $T_2$ 
- extracting from a fully acquisition the distribution of $T_2$ and then generates from that distribution the dictionnary (Tamir et al, MRM,2017)

Let's take a look at the first 6 basis from a linear repartition

```@example exp
using Subspace_MESE

T2_vec = 1.0:1.0:2000.0
TE = 7.0
ETL = 50
NUM_BASIS = 6

basis_exp,_=MESE_basis_exp(NUM_BASIS,TE,ETL,T2_vec)

using CairoMakie
color = Makie.wong_colors()
f = Figure()
ax=Axis(f[1,1])
for b in 1:6
    lines!(ax,abs.(basis_exp[:,b]),color=color[b],label = "Basis n°$b")
end
hidedecorations!(ax)
axislegend(ax)
f
```

# EPG basis
```@docs
MESE_basis_EPG
```

In order to generate the EPG basis, more parameters needs to be defined. Especially the range of $B_1$ to be expected in the acquisition which might be larger for surfacic transmit coil than in our case with a pretty homogeneous $B_1^+$ field with the volumic coil.

To note, B1_vec, T2_vec, T1_vec can also be float value (not vector). In the publication, the T1_vec was fixed to 1000 ms.

```@example epg
using Subspace_MESE
B1_vec = 0.8:0.01:1.0
T2_vec = 1.0:1.0:2000.0
T1_vec = 1000.0 #can also be a float
TE = 7.0
TR = 1000.0
dummy=3
ETL = 50
NUM_BASIS = 6

basis_epg,_=MESE_basis_EPG(NUM_BASIS,TE,ETL,T2_vec,B1_vec,T1_vec;TR=TR,dummy=dummy)

using CairoMakie
color = Makie.wong_colors()
f = Figure()
ax=Axis(f[1,1])
for b in 1:6
    lines!(ax,abs.(basis_epg[:,b]),color=color[b],label = "Basis n°$b")
end
hidedecorations!(ax)
axislegend(ax)
f
```

# Calibration basis

```@docs
basis_calibration
```
The calibration basis reconstructs low-resolution images from a center area. 

You can generate the basis from the acquired accelerated acquisition with a crop_size equal to the size of the calibration data.

But you can also generate the basis from a different fully acquisition.

```julia
b = BrukerFile("path/to/dataset")

raw = RawAcquisitionData_MESE(b)
acq = AcquisitionData(raw,OffsetBruker = true);

basis,_ = MESE_basis_calibration(acq,(15,15,15),6)
```