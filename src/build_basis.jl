export basis_calibration, MESE_basis_exp, MESE_basis_EPG
export MESE_dict_EPG_build, MESE_EPG
####################################
### Create basis
####################################


"""
    basis_calibration(NUM_BASIS::Int,acq::AcquisitionData{T,D},crop_size::NTuple{D,Int}) where {T,D} 
k_bart = kDataCart(acq);  

Extract a temporal basis from a low-resolution images reconstructed using a fully sampled 
area at the center of the k-space with a size `crop_size`. 

## Input : 
    - `NUM_BASIS::Int : Number of temporal basis to extract
    - `acq::AcquisitionData` : Cartesian acquisition with a fully-sampled center.
    - `crop_size::NTuple{D,Int})` : size of the  central part of k-space used

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
function basis_calibration(NUM_BASIS::Int,acq::AcquisitionData{T,D},crop_size::NTuple{D,Int}) where {T,D} 
    k_bart = kDataCart(acq);
    k_bart = reshape(k_bart,collect(size(k_bart)[1:4])...,1,size(k_bart,5));
    
    ##
    sk = size(k_bart)
    k_lowRes = MRICoilSensitivities.crop(k_bart,(crop_size...,sk[4:6]...))
    
    im_lowRes = ifftshift(ifft(fftshift(k_lowRes),(1,2,3)))
    im_lowRes_rss = sqrt.(sum(abs.(im_lowRes) .^ 2, dims = 4))

    calib_dict = reshape(im_lowRes_rss,:,sk[end])
    svd_obj = svd(calib_dict)
    basis = ComplexF32.(svd_obj.V)[:, 1:NUM_BASIS]
        
    return basis,calib_dict
end


"""
        MESE_basis_exp(NUM_BASIS::Int,TE::AbstractFloat,ETL::Int, T2_vec::AbstractVector;removeFirstPoint::Bool=false)

Generate a temporal basis for a Multi-Echo Spin-Echo sequence with an exponential model.for various value of T2 
stored as a vector in `T2_vec`. The first point of the echo train can be removed from the dictionnary 
with the keyword `removeFirstPoint` to minimize the effect of stimulated echoes. 

## Input : 
    - `NUM_BASIS::Int : Number of temporal basis to extract
    - `TE::AbstractFloat` : Cartesian acquisition with a fully-sampled center.
    - `ETL::Int` : Echo Train Length
    - `T2_vec::AbstractVector` : Vector of T₂ values used to generate the signal dictionnary 

## Keyword : 
    - `removeFirstPoint::Bool=False` : Remove the first point of the dictionnary before the svd

## Output :
    - `basis` : Matrix of size (ETL,NUM_BASIS)
    - `exp_dict` : Dictionnary of signal used to generate the basis

## Example :
```julia
T2_vec = 1.0:1.0:2000.0
TE = 7.0
ETL = 50
NUM_BASIS = 6

basis_exp,exp_dict = MESE_basis_exp(NUM_BASIS,TE,ETL,T2_vec)
```
"""
function MESE_basis_exp(NUM_BASIS::Int,TE::AbstractFloat,ETL::Int, T2_vec::AbstractVector;removeFirstPoint::Bool=false)
    
    exp_dict = Matrix{ComplexF64}(undef,length(T2_vec),ETL)

    TE_vec = LinRange(TE,TE*ETL,ETL)
    for i in eachindex(T2_vec)
        exp_dict[i,:] = exp.(-TE_vec/T2_vec[i])
    end

    if removeFirstPoint
        exp_dict = exp_dict[:,2:end]
    end

    svd_obj = svd(exp_dict)
    basis = ComplexF32.(svd_obj.V)[:, 1:NUM_BASIS]

    return basis,exp_dict
end


"""
    MESE_basis_EPG(NUM_BASIS::Int,TE,ETL::Int,T2_vec::Union{AbstractVector,AbstractFloat},B1_vec::Union{AbstractVector,AbstractFloat} = 1.0,T1_vec::Union{AbstractVector,AbstractFloat}=1000.0;TR = 1000.0,dummy::Int = 3)

    Generate a temporal basis for a Multi-Echo Spin-Echo sequence with an Extended Phase Graph model for various value of T2/B1/T1 
stored as a vector in `T2_vec`/`B1_vec`/`T1_vec`.

## Input : 
    - `NUM_BASIS::Int : Number of temporal basis to extract
    - `TE::AbstractFloat` : Cartesian acquisition with a fully-sampled center.
    - `ETL::Int` : Echo Train Length
    - `T2_vec::Union{AbstractVector,AbstractFloat}` : Vector of T₂ values used to generate the signal dictionnary 
    - `B1_vec::Union{AbstractVector,AbstractFloat}` : Vector of B₁ values used to generate the signal dictionnary 
    - `T1_vec::Union{AbstractVector,AbstractFloat}` : Vector of T₁ values used to generate the signal dictionnary 

## Keyword : 
    - `TR` : Repetition time
    - `dummy` : Number of dummy scan before extracting the signal value

## Output :
    - `basis` : Matrix of size (ETL,NUM_BASIS)
    - `epg_dict` : Dictionnary of signal used to generate the basis

## Example :
```julia
B1_vec = 0.8:0.01:1.0
T2_vec = 1.0:1.0:2000.0
T1_vec = 1000.0 #can also be a float
TE = 7.0
TR = 1000.0
dummy=3
ETL = 50
NUM_BASIS = 6

basis_epg, epg_dict =MESE_basis_EPG(NUM_BASIS,TE,ETL,T2_vec,B1_vec,T1_vec;TR=TR,dummy=dummy)
```
"""
function MESE_basis_EPG(NUM_BASIS::Int,TE,ETL::Int,T2_vec::Union{AbstractVector,AbstractFloat},B1_vec::Union{AbstractVector,AbstractFloat} = 1.0,T1_vec::Union{AbstractVector,AbstractFloat}=1000.0;TR = 1000.0,dummy::Int = 3)
    epg_dict = MESE_dict_EPG_build(T2_vec,B1_vec,T1_vec,TE,TR,ETL,dummy)
        
    svd_obj = svd(epg_dict)
    basis = ComplexF32.(svd_obj.V)[:, 1:NUM_BASIS]
    return basis, epg_dict
end

function MESE_dict_EPG_build(T2_vec::Union{AbstractVector,AbstractFloat},B1_vec::Union{AbstractVector,AbstractFloat},T1_vec::Union{AbstractVector,AbstractFloat},TE,TR,ETL,dummy)
    #B1_vec = collect(0.8:0.01:1.0)
    #T2_vec = LinRange(T2Start,T2Stop,T2n)

    epg_dict = Matrix{ComplexF64}(undef,length(T1_vec)*length(B1_vec)*length(T2_vec),ETL)

    counter=0
    for (idx_T1,T1) in enumerate(T1_vec)
        for (idx_B1,B1) in enumerate(B1_vec)
            for (idx_T2,T2) in enumerate(T2_vec)
                counter+=1
                epg_dict[counter,:]= MESE_EPG(T2,T1,TE,TR,ETL,B1,dummy)[:,end]
            end
        end
    end
    return epg_dict
end

"""
    MESE_EPG(T2::Ty,T1::Ty,TE::Ty,TR::Ty,ETL::Int,delta::Ty,dummy::Int) where Ty <: AbstractFloat

    Generate the signal evolution of a Multi-Echo Spin-Echo sequence with an Extended Phase Graph model.

## Input : 
    - `T2` : Transverse relaxation
    - `T1` : Longitudinal relaxation
    - `TE` : Echo Time
    - `TR` : Repetition time
    - `ETL` : Echo Train Length

## Output :
    - Amplitude of each echoes
"""
function MESE_EPG(T2::Ty,T1::Ty,TE::Ty,TR::Ty,ETL::Int,delta::Ty,dummy::Int) where Ty <: AbstractFloat
    T = ComplexF64
    E = EPGStates() # 0,0,1

    # store results
    echo_vec = zeros(T,ETL,dummy)
    # loop over refocusing-pulses
    for d = 1:dummy
        epgRotation!(E,pi/2*delta, pi/2)
        R = rfRotation(pi*delta,0.0)
        for i = 1:ETL
        epgDephasing!(E,1)
        epgRelaxation!(E,TE,T1,T2)
        epgRotation!(E,R)
        epgDephasing!(E,1)
        echo_vec[i,d] = E.Fp[1]
        end
        epgDephasing!(E,3) # rephasing + spoiler 2pi
        epgRelaxation!(E,TR-ETL*TE,T1,T2)
    end
  
    return abs.(echo_vec)
  end