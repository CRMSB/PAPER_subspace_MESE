## Conversion from Bruker dataset to MRIReco.jl object

After acquisition, you can convert the Bruker dataset to an `RawAcquisitionData` with the function spectific function ` RawAcquisitionData_MESE(b::BrukerFile)`. Conversion is mostly performed with MRIReco/MRIBase and MRIFiles functions. 

We need to import them first :

```julia
using Subspace_MESE
using Subspace_MESE.MRIFiles
using Subspace_MESE.MRIReco

b=BrukerFile("path/to/dataset/20230317_085834_AT_MSME_CS_44_1_1/10")
raw = RawAcquisitionData_MESE(b)
```

The RawAcquisitionData object is an implementation of the MRD format.
after that point the remaining function are purely in the MRIReco.jl package. 

In order to perform the reconstruction we need to convert the raw object to an `AcquisitionData` object with the following command :

```julia
acq = AcquisitionData(raw,OffsetBruker = true);
```

The keyword `OffsetBruker` is equal to true in order to correct the offset of the FOV along the phase and partition encoding (specific to Bruker).

## Direct reconstruction 

From that point the user should take a look at the [MRIReco.jl documentation](https://magneticresonanceimaging.github.io/MRIReco.jl/latest/) in order to perfom the reconstruction. 

A direct reconstruction leading to undersampled artifacts can be implemented like :

```julia
params = Dict{Symbol,Any}()
params[:reconSize] = acq.encodingSize
params[:reco] = "direct"

im_u = reconstruction(acq, params);
```

We can combine the different coil elements with a sum of squares :

```julia
using Subspace_MESE.MRICoilSensitivities
im_u_sos = mergeChannels(im_u)
```