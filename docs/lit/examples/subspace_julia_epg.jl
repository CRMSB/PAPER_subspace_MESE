#---------------------------------------------------------
# # [Generate figure 8](@id 03-subspaceReconstruction)
#---------------------------------------------------------

# ## Description
# 
# This example describes how to perform a subspace reconstruction for $T_2$ mapping.
# This script is also used to generate the last figure of the article.
# 
# ![Reconstruction Pipeline](../../img/fig_bart_julia.png)

# ## Reproducibility setup
#
# In order to reproduce figure 8, you need to :
# - compile the BART toolbox : https://mrirecon.github.io/bart/ (you can skip this step if you don't want to plot the BART reconstruction). After compilation/installation you can check the library path with `which bart`
# - download the dataset : https://zenodo.org/records/10610639 and extract the zip file.
# - download the current repository : `git clone https://github.com/aTrotier/PAPER_subspace_MESE`
# - Open a terminal and move to the docs folder in this repository
# - edit the script in `docs/lit/example/subspace_julia_epg.jl` and put the correct path in the variable 
#   - line 46 : `path_raw` should point to the bruker folder `10`
#   - line 49 : `path_bart` should point to the compiled bart library
# - launch julia in the docs folder with this command in the terminal: `julia --project -t auto`
# - run the literate example :
#   ```julia
#   using Pkg
#   Pkg.add(url="https://github.com/aTrotier/PAPER_subspace_MESE")
#   Pkg.instantiate()
#   include("lit/examples/subspace_julia_epg.jl")
#   ```
# The figure will be saved as `fig_bart_julia.png` in the `docs` folder.

# ## Load package
using Subspace_MESE
using Subspace_MESE.MRIFiles
using Subspace_MESE.MRIReco
using Subspace_MESE.MRICoilSensitivities
using Subspace_MESE.LinearAlgebra
using Subspace_MESE.FFTW
using CairoMakie

# ## Define paths
#to the raw dataset :

path_raw = "/workspace_QMRI/PROJECTS_DATA/2021_RECH_mcT2_Bruker/PROJ_JULIA_MSME_CS/data/exp_raw/mouse_patho/20230317_085834_AT_MSME_CS_44_1_1/10"

#and to the bart library :
path_bart = "/home/CODE/bart/bart" 

slice_to_show = 55
# ## Load and convert the bruker dataset into an AcquisitionData object
b = BrukerFile(path_raw)

raw = RawAcquisitionData_MESE(b)
acq = AcquisitionData(raw,OffsetBruker = true);

# ## Estimate the coil sensitivity map with espirit
coilsens = espirit(acq,eigThresh_2=0.0);

# ## Direct reconstruction of undersampled acquisition

params = Dict{Symbol,Any}()
params[:reconSize] = acq.encodingSize
params[:reco] = "direct"

im_u = reconstruction(acq, params);
im_u_sos = mergeChannels(im_u)

heatmap(im_u_sos[:,:,55,15,1,1],colormap=:grays)

# ##  Subspace generation with the EPG simulation
B1_vec = 0.8:0.01:1.0
T2_vec = 1.0:1.0:2000.0
T1_vec = 1000.0
TE = 7.0
TR = 1000.0
dummy=3
ETL = 50
NUM_BASIS = 6
basis_epg,_= MESE_basis_EPG(NUM_BASIS,TE,ETL,T2_vec,B1_vec,T1_vec;TR=TR,dummy=dummy)
lines(abs.(basis_epg[:,2]))

# ## Subspace reconstruction with EPG dictionary
params = Dict{Symbol,Any}()
params[:reconSize] = acq.encodingSize
params[:reco] = "multiCoilMultiEchoSubspace"

params[:regularization] = "L1"
params[:sparseTrafo] = "Wavelet" #sparse trafo
params[:λ] = Float32(0.03)
params[:solver] = "fista"
params[:iterations] = 60
#params[:iterationsInner] = 5
params[:senseMaps] = coilsens
params[:normalizeReg] = true
params[:basis] = basis_epg

α_epg = reconstruction(acq, params)
im_TE_julia = abs.(applySubspace(α_epg, params[:basis]));

# ## BART reconstruction
# In order to use BartIO, we need to send the path to the bart library.
# You can check that it works with the following code
# ```julia
# BartIO.set_bart_path("path_bart")
# bart()
# ```

if isfile(path_bart)
    using Subspace_MESE.BartIO

    params[:λ] = Float32(0.0025)
    im_sub_bart,im_TE_bart = subspace_bart_reconstruction(acq,params,path_bart)
end;

# ## Fitting of the data to obtain T₂ maps

TE_vec = Float32.(LinRange(TE,TE*ETL,ETL))

sl = Tuple[]
push!(sl,(:,:,slice_to_show))
push!(sl,(:,65,:))
push!(sl,(65,:,:))

fit_und = Any[]
fit_julia = Any[]
fit_bart = Any[]
for i in eachindex(sl)
    push!(fit_und,Subspace_MESE.T2Fit_exp_noise(abs.(im_u_sos[sl[i]...,:,1,1]),TE_vec;removePoint=true,L=4))
    push!(fit_julia,Subspace_MESE.T2Fit_exp_noise(abs.(im_TE_julia[sl[i]...,:,1,1]),TE_vec;removePoint=true,L=4))
    if isfile(path_bart)
        push!(fit_bart,Subspace_MESE.T2Fit_exp_noise(abs.(im_TE_bart[sl[i]...,1,1,:]),TE_vec;removePoint=true,L=4))
    end;
end

# ## Visualization of the article figure 8

using CairoMakie.Makie.MakieCore
begin
titlesize=20
ylabelsize=20
aspect = DataAspect()

f=Figure(size=(1200,1600))
#plot echo 1
colorrange=MakieCore.Automatic()
colormap=:grays

ax = Axis(f[1,1];title="FFT\n ",ylabel = "Echo n°1\nTE = 7 ms",titlesize,ylabelsize)
heatmap!(ax,circshift(im_u_sos[:,:,slice_to_show,1,1,1],(0,-10));colorrange,colormap)
hidedecorations!(ax,label=false)
ax = Axis(f[1,2];title="MRIReco\nW=0.03",titlesize)
heatmap!(ax,circshift(im_TE_julia[:,:,slice_to_show,1,1,1],(0,-10));colorrange,colormap)
hidedecorations!(ax)

if(isfile(path_bart))
    ax = Axis(f[1,3];title="BART\nW=0.0025",titlesize)
    heatmap!(ax,circshift(abs.(im_TE_bart[:,:,slice_to_show,1,1,1]),(0,-10));colorrange,colormap)
    hidedecorations!(ax)
end

#plot echo 10

ax = Axis(f[2,1];ylabel = "Echo n°10\nTE = 70 ms",titlesize,ylabelsize)
heatmap!(ax,circshift(im_u_sos[:,:,slice_to_show,10,1,1],(0,-10));colorrange,colormap)
hidedecorations!(ax,label=false)
ax = Axis(f[2,2];titlesize)
heatmap!(ax,circshift(im_TE_julia[:,:,slice_to_show,10,1,1],(0,-10));colorrange,colormap)
hidedecorations!(ax)

if(isfile(path_bart))
    ax = Axis(f[2,3];titlesize)
    heatmap!(ax,circshift(abs.(im_TE_bart[:,:,slice_to_show,1,1,10]),(0,-10));colorrange,colormap)
    hidedecorations!(ax)
end

#plot T2 map
colorrange=(0,150)
colormap=:magma

ax = Axis(f[3,1];ylabel = "T₂ map: coronal",titlesize,ylabelsize)
heatmap!(ax,circshift(fit_und[1][:,:,2],(0,-10));colorrange,colormap)
hidedecorations!(ax,label=false)
ax = Axis(f[3,2])
h=heatmap!(ax,circshift(fit_julia[1][:,:,2],(0,-10));colorrange,colormap)
hidedecorations!(ax)
if(isfile(path_bart))
    ax = Axis(f[3,3])
    heatmap!(ax,circshift(fit_bart[1][:,:,2],(0,-10));colorrange,colormap)
    hidedecorations!(ax)
end
Colorbar(f[3,4],h,label = "T₂ [ms]",labelrotation=-pi/2,labelsize=20)
#rowgap!(f.layout,3,10)

#plot T2 sag
sl_c = (0,20)
ax = Axis(f[4,1];ylabel = "T₂ map: sagittal",titlesize,ylabelsize,aspect=128/96)
heatmap!(ax,circshift(reverse(fit_und[2][:,:,2],dims=2),sl_c);colorrange,colormap)
hidedecorations!(ax,label=false)
ax = Axis(f[4,2],aspect=128/96)
h=heatmap!(ax,circshift(reverse(fit_julia[2][:,:,2],dims=2),sl_c);colorrange,colormap)
hidedecorations!(ax)
if(isfile(path_bart))
    ax = Axis(f[4,3],aspect=128/96)
    heatmap!(ax,circshift(reverse(fit_bart[2][:,:,2],dims=2),sl_c);colorrange,colormap)
    hidedecorations!(ax)
end
Colorbar(f[4,4],h,label = "T₂ [ms]",labelrotation=-pi/2,labelsize=20,height=Relative(0.85))
rowgap!(f.layout,3,-10)

#plot T2 axial
sl_c = (-10,20)
ax = Axis(f[5,1];ylabel = "T₂ map : axial",titlesize,ylabelsize,aspect=128/96)
heatmap!(ax,circshift(reverse(fit_und[3][:,:,2],dims=2),sl_c);colorrange,colormap)
hidedecorations!(ax,label=false)
ax = Axis(f[5,2],aspect=128/96)
h=heatmap!(ax,circshift(reverse(fit_julia[3][:,:,2],dims=2),sl_c);colorrange,colormap)
hidedecorations!(ax)
if(isfile(path_bart))
    ax = Axis(f[5,3],aspect=128/96)
    heatmap!(ax,circshift(reverse(fit_bart[3][:,:,2],dims=2),sl_c);colorrange,colormap)
    hidedecorations!(ax)
end
Colorbar(f[5,4],h,label = "T₂ [ms]",labelrotation=-pi/2,labelsize=20,height=Relative(0.85))
rowgap!(f.layout,4,-35)

f
end

save("fig_bart_julia.png",f)
save("fig_bart_julia.eps",f)
save("fig_bart_julia.pdf",f)
