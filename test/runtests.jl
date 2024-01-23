using Subspace_MESE
using Test

@testset "Subspace_MESE.jl" begin
    # Subspace reconstruction is tested in MRIReco.jl package
    
    # test for the creation of subspace 

    using Subspace_MESE

    T2_vec = 1.0:1.0:2000.0
    TE = 7.0
    ETL = 50
    NUM_BASIS = 6

    basis_exp,_=MESE_basis_exp(NUM_BASIS,TE,ETL,T2_vec)

    @test size(basis_exp) == (50,6)

    TE_vec = LinRange(TE,TE*ETL,ETL)
    S = exp.(-TE_vec/50.0)

    sub_coeff = [-1.0772590045860388 + 0.0im
                1.2802252819294175 + 0.0im
                0.5415142715859474 + 0.0im
                -0.02782074587624846 + 0.0im
                -0.03359393736873703 + 0.0im
                0.011127148608210662 + 0.0im]

  @test (basis_exp' * S) == sub_coeff


  ## test epg

    B1_vec = 0.8:0.01:1.0
    T2_vec = 1.0:1.0:2000.0
    T1_vec = 1000.0 #can also be a float
    TE = 7.0
    TR = 1000.0
    dummy=3
    ETL = 50
    NUM_BASIS = 6

    basis_epg, epg_dict =MESE_basis_EPG(NUM_BASIS,TE,ETL,T2_vec,B1_vec,T1_vec;TR=TR,dummy=dummy)

    @test size(basis_epg) == (50,6)


    sub_coeff_epg = [-1.0740504815443557 + 0.0im
                     1.2817868908353707 + 0.0im
                    -0.5439191557331762 + 0.0im
                    -0.018470903467966614 + 0.0im
                    -0.016334777675753444 + 0.0im
                    0.03795672696448779 + 0.0im]

    @test (basis_epg' * S) == sub_coeff_epg
    
    
end
