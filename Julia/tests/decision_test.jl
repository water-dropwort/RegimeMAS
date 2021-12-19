using Test
include("../decision.jl")

@testset verbose=true "decision_test_set" begin
    @testset "shares" begin
        regimes = [1 3 4;
                   2 2 5;
                   3 4 2]
        @test shares(regimes,5) == [1/9, 3/9, 2/9, 2/9, 1/9]

        regimes = [1 3 5 1;
                   2 3 3 4;
                   4 5 5 1;
                   1 1 2 1]
        @test shares(regimes,5) == [6/16, 2/16, 3/16, 2/16, 3/16]
    end

    @testset "lshares" begin
        regimes = [1 3 5 2;
                   2 3 3 4;
                   4 5 5 1;
                   3 1 2 5]
        _lshares(center) = lshares(center, regimes, 5, 4)
        @test _lshares((1,1)) == [1,2,3,1,1] ./ 8
        @test _lshares((3,2)) == [1,2,3,1,1] ./ 8
        @test _lshares((2,3)) == [1,1,2,1,3] ./ 8
    end

    @testset "best_regime" begin
        @test best_regime([0.4, 0.2, 0.5, 0.6, 0.0]) == 4
        @test best_regime([0.5, 0.5, 0.5, 0.5, 0.5]) == 5
    end

    @testset "calc_prefs" begin
        gidprf = [0.4, 0.5, 0.6, 0.1, 0.2]
        gshares = [0.2, 0.3, 0.1, 0.15, 0.25]
        lshares = [1,2,3,1,1] ./ 8
        gregime = 4
        iregime = 3
        nregime = 1
        gweights = [3,1,2,4,5]
        iweights = [4,1,2]
        gprefs = calc_gprefs(gidprf, gshares, lshares, iregime, nregime, 5, gweights)
        iprefs = calc_i_n_prefs(gidprf, gshares, gregime, 5, iweights)
        for i in (1:5)
            @test gprefs[i] == dot(gweights, [gidprf[i], gshares[i], lshares[i], bool2bin(i==nregime), bool2bin(i==iregime)])
            @test iprefs[i] == dot(iweights, [gidprf[i], gshares[i], bool2bin(i==gregime)])
        end
    end
end
