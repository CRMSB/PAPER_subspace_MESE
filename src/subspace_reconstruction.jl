export subspace_bart_reconstruction

"""
    subspace_bart_reconstruction(acq::AcquisitionData,params::Dict{Symbol,Any},bart_path::AbstractString)


Reconstruction of the accelerated MESE sequence with BART.

## Input : 
    - `acq::AcquisitionData` : Cartesian acquisition with a fully-sampled center.
    - `params::Dict{Symbol,Any}` : size of the  central part of k-space used
    - `bart_path::AbstractString` : path to the BART executable library
## Output :
    - `basis` : Matrix of size (ETL,NUM_BASIS)
    - `calib_dict` : Dictionnary of signal used to generate the basis

## Example :
```julia
b = BrukerFile("path/to/dataset")

raw = RawAcquisitionData_MESE(b)
acq = AcquisitionData(raw,OffsetBruker = true);

basis, calib_dict = MESE_basis_calibration(acq,(15,15,15),6)
```
"""
function subspace_bart_reconstruction(acq::AcquisitionData,params::Dict{Symbol,Any},bart_path::AbstractString)

    BartIO.set_bart_path(bart_path)

    k_bart = kDataCart(acq)

    k_bart = reshape(k_bart,collect(size(k_bart)[1:4])...,1,size(k_bart,5));

    ## process sensitivity maps
    #sens = bart(1,"ecalib -d3 -m1 -c 0.0",k_bart[:,:,:,:,1,1])

    ## convert basis to bart format
    basis = bart(1,"transpose 1 6",params[:basis]);
    basis = bart(1,"transpose 0 5",basis);

    im_SUB = bart(1,"pics -d5 -S -e -i $(params[:iterations]) -R W:7:0:$(params[:λ])",k_bart,params[:senseMaps],B = basis);
    im_TE = bart(1,"fmac -s 64",basis,im_SUB);
    return im_SUB, im_TE
end
