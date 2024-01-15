
using LsqFit
using EPGsim

export T2Fit_exp_noise, T2Fit_epg_noise

"""
        T2Fit_exp_noise(ima::Array{T,N}, t::AbstractVector{T}; removePoint::Bool=true, L::Int=1, mask = nothing) where {T<:Real,N}

Fit the relaxation parameters T2 with the equation : ``S(t) = \\sqrt{(M_0 \\exp(-\\frac{t}{T2}))^2 + 2 L \\sigma_g^2}``
where L est le nombre de canaux, et ``\\sigma_g`` le bruit gaussien sur les image

# Arguments
- `ima::Array{T,N}`: multi-dimensionnal images. Last dimension stores the temporal dimension
- `t::AbstractVector{<:Real}`: times vector in ms
- `p0=nothing`: starting values for fit, if empty p0=[maximum(ima),30,maximum(ima)*0.1]

# Keywords
- `removePoint::Bool=true`: remove the first point before fitting
- `L::Int=1`: Number of coil elements
- `mask::`

# Returns
- fit_params : parameter maps last dimension stores the following maps (M₀ , T₂ , σ)

# Bibliography
- Cárdenas-Blanco A, Tejos C, Irarrazaval P, Cameron I. Noise in magnitude magnetic
resonance images. Concepts Magn Reson Part A [Internet]. 2008 Nov;32A(6):409?16. Available
from: http://doi.wiley.com/10.1002/cmr.a.20124
- Feng Y, He T, Gatehouse PD, Li X, Harith Alam M, Pennell DJ, et al. Improved MRI R 2 *
relaxometry of iron-loaded liver with noise correction. Magn Reson Med [Internet]. 2013
Dec;70(6):1765?74. Available from: http://doi.wiley.com/10.1002/mrm.24607
"""
function T2Fit_exp_noise(ima::Array{T,N}, t::AbstractVector{T}; removePoint::Bool=true, L::Int=1, mask = nothing) where {T<:Real,N}
dims = size(ima)
@assert dims[end] == length(t)
if isnothing(mask)
    mask = ones(eltype(ima),dims[1:end-1])
end
ima = reshape(ima, :, dims[end])'

if removePoint
    t = t[2:end]
    ima = ima[2:end,:]
end

model(t, p) = sqrt.((p[1] * exp.(-t / p[2])) .^ 2 .+ 2 * L * p[3]^2)

fit_param = zeros(eltype(ima),size(ima, 2),3)

for i = 1:size(ima, 2)
    if mask[i]==1
        try
            y = view(ima,:,i)
            p0 = [maximum(y), T.(30),minimum(y)]
            fit_param[i,:] = curve_fit(model, t, y, p0,autodiff=:forwarddiff).param
        catch
            fit_param[i,:] .= NaN
        end
    else
        fit_param[i,:] .= NaN
    end
end

return reshape(fit_param,dims[1:N-1]...,:)
end


"""
    T2Fit_epg_noise(ima::Array{T,N}, t::AbstractVector{T},T1=1000.0,TE=7.0; EPGthresh = 1e-5,p0=nothing,mask = nothing) where {T<:Real,N}

**WIP**
"""
function T2Fit_epg_noise(ima::Array{T,N}, t::AbstractVector{T},T1=1000.0,TE=7.0; EPGthresh = 1e-5,p0=nothing,mask = nothing) where {T<:Real,N}
  
    function model(t,x)
      TT = eltype(complex(x))
      E = EPGStates([TT(0.0)],[TT(0.0)],[TT(1.0)])
      echo_vec = Vector{Complex{eltype(x)}}()
    
      epgRotation!(E,pi/2*x[3], pi/2)
      R = rfRotation(pi*x[3],0.0)
      # loop over refocusing-pulses
      for i = 1:length(t)
        epgDephasing!(E,1,EPGthresh)
        epgRelaxation!(E,TE,T1,x[2])
        epgRotation!(E,R)
        epgDephasing!(E,1,EPGthresh)
        push!(echo_vec,E.Fp[1])
      end
    
      return sqrt.(abs.(x[1]*echo_vec).^2 .+ x[4]^2)
    end
    
    dims = size(ima)
    @assert dims[end] == length(t)

    if isnothing(mask)
        mask = ones(eltype(ima),dims[1:end-1])
    end
    ima = reshape(ima, :, dims[end])'
  
    fit_param = zeros(eltype(ima),size(ima, 2),4)
  
    lowerB = [0.0,0.0,0.0,0.0]
    upperB = [Inf,Inf,1.0,Inf]
    Threads.@threads  for i in 1:size(ima, 2)
        if mask[i]==1
            try
            y = view(ima,:,i)
            p0 = [maximum(y), T.(30),1.0,minimum(y)]
                fit_param[i,:] = curve_fit(model, t, y, p0,lower = lowerB,upper = upperB).param
            catch e
                fit_param[i,:] .= NaN
            end
        else
            fit_param[i,:] .= NaN
        end
    end
  
    return reshape(fit_param,dims[1:N-1]...,:), model
  end