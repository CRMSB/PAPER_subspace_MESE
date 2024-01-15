export RawAcquisitionData_MESE

"""
    RawAcquisitionData_MESE(b::BrukerFile)

Convert a Bruker dataset acquired with the a_MESE_CS sequence into a 
`RawAcquisitionData` object compatible with the MRIReco functions.

Input : 
    - b::BrukerFile

Output :
    - raw::RawAcquisitionData
"""
function RawAcquisitionData_MESE(b::BrukerFile)
    T = Complex{MRIFiles.acqDataType(b)}

    filename = joinpath(b.path, "fid")
    filenameTraj = joinpath(b.path, "traj")

    N = MRIFiles.acqSize(b)
    sx = MRIFiles.pvmMatrix(b)[1]
    sy = MRIFiles.pvmMatrix(b)[2]
    sz = MRIFiles.pvmMatrix(b)[3]

    # The data is padded in case it is not a multiple of 1024 
    # For multi-channel acquisition data at concatenate then padded to a multiple of 1024 bytes
    numChannel = MRIFiles.pvmEncNReceivers(b)
    profileLength = Int((ceil(N[1]*numChannel*sizeof(T)/1024))*1024/sizeof(T))
    numAvailableChannel = MRIFiles.pvmEncAvailReceivers(b)
    phaseFactor = MRIFiles.acqPhaseFactor(b)
    numSlices = MRIFiles.acqNumSlices(b)
    numEchos = MRIFiles.acqNumEchos(b)
    numEncSteps2 = length(N) == 3 ? N[3] : 1
    numRep = MRIFiles.acqNumRepetitions(b)

    gradMatrix = MRIFiles.acqGradMatrix(b)
    offset1 = MRIFiles.acqReadOffset(b)
    offset2 = MRIFiles.acqPhase1Offset(b)
    offset3 = ndims(b) == 2 ? MRIFiles.acqSliceOffset(b) : MRIFiles.pvmEffPhase2Offset(b)

    I = open(filename,"r") do fd
      read!(fd,Array{T,4}(undef, profileLength,
                                     numEchos,
                                     N[2],
                                     numRep))[1:N[1]*numChannel,:,:,:]
    end

    I2 = permutedims(I,(1,3,2,4)); # put echos in last dimension
    I2 = reshape(I2,N[1],numChannel,N[2],numEchos,numRep) # -> sx, nCh,proj,echos,rep  


    # extract position of rawdata
    GradPhaseVect = parse.(Float32,b["GradPhaseVector"])
    GradPhaseVect=GradPhaseVect*sy/2;
    GradPhaseVect=round.(Int,(GradPhaseVect.-minimum(GradPhaseVect)));
    

    GradSliceVect = parse.(Float32,b["GradSliceVector"])
    GradSliceVect=GradSliceVect*sz/2;
    GradSliceVect=round.(Int,(GradSliceVect.-minimum(GradSliceVect)))


    # case fully -> only one mask is generated need to repmat it
    if b["EnableCS"] == "Fully"
        GradPhaseVect = repeat(vec(GradPhaseVect),1,numEchos)'
        GradSliceVect = repeat(vec(GradSliceVect),1,numEchos)'
    end

    GradPhaseVect = reshape(GradPhaseVect,numEchos,:)
    GradSliceVect = reshape(GradSliceVect,numEchos,:)

    # create profile 
    profiles = MRIReco.Profile[]
    for nR = 1:numRep
        for nEcho=1:numEchos
            for nEnc = 1:N[2]
            
            counter = EncodingCounters(kspace_encode_step_1=GradPhaseVect[nEcho,nEnc],
            kspace_encode_step_2=GradSliceVect[nEcho,nEnc],
            average=0,
            slice=0,
            contrast=nEcho-1,
            phase=0,
            repetition=nR-1,
            set=0,
            segment=0)

            nSl = 1
            G = gradMatrix[:,:,nSl]
                    read_dir = (G[1,1],G[2,1],G[3,1])
                    phase_dir = (G[1,2],G[2,2],G[3,2])
                    slice_dir = (G[1,3],G[2,3],G[3,3])

            # Not sure if the following is correct...
            pos = offset1[nSl]*G[:,1] +
                    offset2[nSl]*G[:,2] +
                    offset3[nSl]*G[:,3]

            position = (pos[1], pos[2], pos[3])

            head = AcquisitionHeader(number_of_samples=sx, idx=counter,
                                        read_dir=read_dir, phase_dir=phase_dir,
                                        slice_dir=slice_dir, position=position,
                                        center_sample=div(sx,2),
                                        available_channels = numChannel, #TODO
                                        active_channels = numChannel)
            traj = Matrix{Float32}(undef,0,0)
            dat = map(ComplexF32, reshape(I2[:,:,nEnc,nEcho,nR],:,numChannel))
            push!(profiles, MRIReco.Profile(head,traj,dat) )
            end
        end
    end

    params = MRIFiles.brukerParams(b)
    params["trajectory"] = "cartesian"
    params["encodedSize"] =[sx;sy;sz]

    return MRIReco.RawAcquisitionData(params, profiles)
end